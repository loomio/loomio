module RetainedRecordCountRebuild
  # Frozen migration SQL also seeds counts after callback-free fixture loading.
  # Rebuild every retained value, including zeroes, before switching from
  # recounts to deltas; historical drift must not become the new baseline.
  def self.run(connection)
    connection.execute(<<~SQL)
      UPDATE groups SET
        memberships_count = (SELECT COUNT(*) FROM memberships m WHERE m.group_id = groups.id AND m.revoked_at IS NULL),
        pending_memberships_count = (SELECT COUNT(*) FROM memberships m WHERE m.group_id = groups.id AND m.revoked_at IS NULL AND m.accepted_at IS NULL),
        admin_memberships_count = (SELECT COUNT(*) FROM memberships m WHERE m.group_id = groups.id AND m.revoked_at IS NULL AND m.admin = TRUE),
        polls_count = (SELECT COUNT(*) FROM polls p JOIN topics t ON t.id = p.topic_id WHERE t.group_id = groups.id),
        discussions_count = (SELECT COUNT(*) FROM discussions d JOIN topics t ON t.id = d.topic_id WHERE t.group_id = groups.id AND d.discarded_at IS NULL),
        poll_templates_count = (SELECT COUNT(*) FROM poll_templates pt WHERE pt.group_id = groups.id AND pt.discarded_at IS NULL),
        subgroups_count = (SELECT COUNT(*) FROM groups children WHERE children.parent_id = groups.id AND children.discarded_at IS NULL),
        org_members_count = (
          SELECT COUNT(DISTINCT m.user_id) FROM memberships m
          WHERE m.revoked_at IS NULL AND (m.group_id = groups.id OR m.group_id IN (SELECT id FROM groups children WHERE children.parent_id = groups.id))
        )
    SQL
    connection.execute(<<~SQL)
      UPDATE users SET memberships_count = (
        SELECT COUNT(*) FROM memberships m WHERE m.user_id = users.id AND m.revoked_at IS NULL
      )
    SQL
    connection.execute(<<~SQL)
      UPDATE topics SET
        active_polls_count = (SELECT COUNT(*) FROM polls p WHERE p.topic_id = topics.id AND p.discarded_at IS NULL AND p.closed_at IS NULL AND p.opened_at IS NOT NULL),
        seen_by_count = (SELECT COUNT(*) FROM topic_readers tr WHERE tr.topic_id = topics.id AND tr.last_read_at IS NOT NULL)
    SQL
    connection.execute(<<~SQL)
      WITH counts AS MATERIALIZED (
        SELECT items.id, COALESCE(children.count, 0) AS child_count
        FROM topic_items items
        LEFT JOIN (SELECT parent_id, COUNT(*) AS count FROM topic_items WHERE parent_id IS NOT NULL GROUP BY parent_id) children
          ON children.parent_id = items.id
      )
      UPDATE topic_items SET child_count = counts.child_count FROM counts
      WHERE topic_items.id = counts.id AND topic_items.child_count IS DISTINCT FROM counts.child_count
    SQL
    %w[discussions comments outcomes].each do |table|
      type = { 'discussions' => 'Discussion', 'comments' => 'Comment', 'outcomes' => 'Outcome' }.fetch(table)
      connection.execute(<<~SQL)
        UPDATE #{table} SET versions_count = (
          SELECT COUNT(*) FROM versions v WHERE v.item_type = '#{type}' AND v.item_id = #{table}.id
        )
      SQL
    end
  end
end
