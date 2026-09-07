# Cleans up root trial groups after their subscription has been expired for the
# retention period. Untouched group trees are deleted immediately. Trials with
# any evidence of use are archived, their administrators are warned, and the
# exact archive operation is scheduled for deletion after the warning period.
module TrialCleanupService
  RETENTION_PERIOD = 60.days
  WARNING_PERIOD = 2.weeks
  BATCH_SIZE = 100
  REFERENCE_TABLES = %i[groups subscriptions topics memberships discussion_templates poll_templates membership_requests chatbots tags active_storage_attachments received_emails group_identities group_surveys group_handle_redirects member_email_aliases webhooks demos].freeze

  def self.audit(expires_before: RETENTION_PERIOD.ago)
    eligible_ids = eligible_groups(expires_before: expires_before).pluck(:id)
    unused_ids = unused_groups(expires_before: expires_before).where(id: eligible_ids).pluck(:id)
    result = {
      eligible: eligible_ids.size,
      unused: unused_ids.size,
      used: eligible_ids.size - unused_ids.size
    }

    puts "Expired trial group trees: #{result[:eligible]} (#{result[:unused]} unused, #{result[:used]} used)"
    result
  end

  def self.cleanup!(limit: BATCH_SIZE, expires_before: RETENTION_PERIOD.ago)
    group_ids = eligible_groups(expires_before: expires_before).order("subscriptions.expires_at", :id).limit(limit).pluck(:id)
    result = { deleted: 0, warned: 0, deferred: 0 }

    group_ids.each do |group_id|
      outcome = cleanup_group!(group_id, expires_before: expires_before)
      result[outcome || :deferred] += 1
    end

    puts "Cleaned expired trials: #{result[:deleted]} deleted, #{result[:warned]} warned, #{result[:deferred]} deferred"
    result
  end

  # The eligibility decision and destructive action share one lock window so a
  # new reference cannot turn an untouched trial into a used one between them.
  def self.cleanup_group!(group_id, expires_before: RETENTION_PERIOD.ago)
    CleanupService.with_write_lock(REFERENCE_TABLES) do
      group = eligible_groups(expires_before: expires_before, root_id: group_id).lock.first
      next unless group

      if unused_groups(expires_before: expires_before, root_id: group_id).exists?(id: group.id)
        group.destroy!
        :deleted
      else
        warn_and_schedule!(group)
        :warned
      end
    end
  end

  def self.eligible_groups(expires_before: RETENTION_PERIOD.ago, root_id: nil)
    scope = Group.expired_trial(expires_before).where(archived_at: nil)
    root_id ? scope.where(id: root_id) : scope
  end

  def self.unused_groups(expires_before: RETENTION_PERIOD.ago, root_id: nil)
    sql = Group.sanitize_sql_array([ unused_root_ids_sql, { expires_before: expires_before, root_id: root_id } ])
    Group.where(id: Group.connection.select_values(sql))
  end

  # Build each eligible root's complete descendant tree before checking use.
  # Historical activity such as discarded topics or revoked memberships makes
  # a trial used and therefore entitled to the warning period.
  def self.unused_root_ids_sql
    <<~SQL.squish
      WITH RECURSIVE eligible_roots AS (
        SELECT groups.id
        FROM groups
        JOIN subscriptions ON subscriptions.id = groups.subscription_id
        WHERE groups.parent_id IS NULL
          AND groups.archived_at IS NULL
          AND subscriptions.plan = 'trial'
          AND subscriptions.expires_at < :expires_before
          AND (:root_id IS NULL OR groups.id = :root_id)
      ), group_tree(root_id, group_id) AS (
        SELECT eligible_roots.id, eligible_roots.id
        FROM eligible_roots
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
      ), used_roots AS (
        SELECT DISTINCT reasons.root_id
        FROM (
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
          SELECT group_tree.root_id FROM group_tree JOIN received_emails ON received_emails.group_id = group_tree.group_id
          UNION ALL
          SELECT group_tree.root_id FROM group_tree JOIN group_identities ON group_identities.group_id = group_tree.group_id
          UNION ALL
          SELECT group_tree.root_id FROM group_tree JOIN group_surveys ON group_surveys.group_id = group_tree.group_id
          UNION ALL
          SELECT group_tree.root_id FROM group_tree JOIN demos ON demos.group_id = group_tree.group_id
          UNION ALL
          SELECT group_tree.root_id FROM group_tree JOIN webhooks ON webhooks.group_id = group_tree.group_id
          UNION ALL
          SELECT group_tree.root_id FROM group_tree JOIN member_email_aliases ON member_email_aliases.group_id = group_tree.group_id
          UNION ALL
          SELECT group_tree.root_id FROM group_tree JOIN group_handle_redirects ON group_handle_redirects.group_id = group_tree.group_id
          UNION ALL
          SELECT group_tree.root_id FROM group_tree JOIN active_storage_attachments ON active_storage_attachments.group_id = group_tree.group_id
          UNION ALL
          SELECT group_tree.root_id
          FROM group_tree
          JOIN active_storage_attachments
            ON active_storage_attachments.record_type = 'Group'
           AND active_storage_attachments.record_id = group_tree.group_id
        ) reasons
      )
      SELECT eligible_roots.id
      FROM eligible_roots
      LEFT JOIN membership_rollups ON membership_rollups.root_id = eligible_roots.id
      LEFT JOIN used_roots ON used_roots.root_id = eligible_roots.id
      WHERE used_roots.root_id IS NULL
        AND COALESCE(membership_rollups.user_count, 0) < 2
        AND COALESCE(membership_rollups.has_revoked, FALSE) = FALSE
    SQL
  end

  def self.warn_and_schedule!(group)
    admin_ids = group.admins.pluck(:id)
    group.archive!
    archived_at = group.archived_at.iso8601(6)
    ActiveRecord::Base.current_transaction.after_commit do
      admin_ids.each { |admin_id| GroupMailer.trial_expired(group.id, admin_id).deliver_later }
      DestroyGroupWorker.set(wait: WARNING_PERIOD).perform_later(group.id, archived_at)
    end
  end

  private_class_method :unused_root_ids_sql, :warn_and_schedule!
end
