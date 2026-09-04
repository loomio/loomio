# Finds old, unused group trees and schedules their deletion. A root is only
# eligible when every descendant is equally empty; evidence of historical use
# such as discarded topics or revoked memberships preserves the whole tree.
module EmptyGroupCleanupService
  CREATED_BEFORE = 1.year.ago

  def self.audit
    count = candidate_groups.count
    puts "Empty group trees eligible for deletion: #{count}"
    count
  end

  def self.enqueue!(limit: nil)
    group_ids = candidate_groups.order(:id).limit(limit).pluck(:id)
    count = 0

    group_ids.each do |group_id|
      next unless candidate_groups.exists?(group_id)

      GroupService.destroy_without_warning!(group_id)
      count += 1
    end

    puts "Scheduled #{count} empty group trees for deletion"
    count
  end

  def self.candidate_groups(created_before: CREATED_BEFORE)
    sql = Group.sanitize_sql_array([ eligible_root_ids_sql, { created_before: created_before } ])
    group_ids = Group.connection.select_values(sql)
    Group.where(id: group_ids)
  end

  # Build every root's complete descendant tree first. The anti-joins then
  # preserve a root when any group in its tree contains current or historical
  # activity, including records hidden by normal kept/active scopes.
  def self.eligible_root_ids_sql
    <<~SQL.squish
      WITH RECURSIVE group_tree(root_id, group_id) AS (
        SELECT groups.id, groups.id
        FROM groups
        WHERE groups.parent_id IS NULL
        UNION ALL
        SELECT group_tree.root_id, subgroups.id
        FROM group_tree
        JOIN groups subgroups ON subgroups.parent_id = group_tree.group_id
      ), membership_rollups AS (
        SELECT group_tree.root_id,
               COUNT(DISTINCT memberships.user_id) AS user_count,
               BOOL_OR(memberships.revoked_at IS NOT NULL) AS has_revoked
        FROM group_tree
        JOIN memberships ON memberships.group_id = group_tree.group_id
        GROUP BY group_tree.root_id
      ), disqualified_roots AS (
        SELECT DISTINCT reasons.root_id
        FROM (
          SELECT group_tree.root_id
          FROM group_tree
          JOIN groups tree_groups ON tree_groups.id = group_tree.group_id
          LEFT JOIN subscriptions ON subscriptions.id = tree_groups.subscription_id
          WHERE tree_groups.created_at >= :created_before
             OR (
               tree_groups.subscription_id IS NOT NULL AND
               (subscriptions.plan IS DISTINCT FROM 'free' OR subscriptions.state IS DISTINCT FROM 'active')
             )
          UNION ALL
          SELECT group_tree.root_id FROM group_tree JOIN topics ON topics.group_id = group_tree.group_id
          UNION ALL
          SELECT group_tree.root_id FROM group_tree JOIN discussion_templates ON discussion_templates.group_id = group_tree.group_id
          UNION ALL
          SELECT group_tree.root_id FROM group_tree JOIN poll_templates ON poll_templates.group_id = group_tree.group_id
          UNION ALL
          SELECT group_tree.root_id FROM group_tree JOIN membership_requests ON membership_requests.group_id = group_tree.group_id
          UNION ALL
          SELECT group_tree.root_id FROM group_tree JOIN chatbots ON chatbots.group_id = group_tree.group_id
          UNION ALL
          SELECT group_tree.root_id FROM group_tree JOIN tags ON tags.group_id = group_tree.group_id
          UNION ALL
          SELECT group_tree.root_id
          FROM group_tree
          JOIN active_storage_attachments
            ON active_storage_attachments.record_type = 'Group'
           AND active_storage_attachments.record_id = group_tree.group_id
        ) reasons
      )
      SELECT roots.id
      FROM groups roots
      LEFT JOIN membership_rollups ON membership_rollups.root_id = roots.id
      LEFT JOIN disqualified_roots ON disqualified_roots.root_id = roots.id
      WHERE roots.parent_id IS NULL
        AND disqualified_roots.root_id IS NULL
        AND COALESCE(membership_rollups.user_count, 0) < 2
        AND COALESCE(membership_rollups.has_revoked, FALSE) = FALSE
    SQL
  end

  private_class_method :eligible_root_ids_sql
end
