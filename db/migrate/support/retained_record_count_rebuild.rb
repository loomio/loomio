module RetainedRecordCountRebuild
  # Frozen migration SQL also seeds counts after callback-free fixture loading.
  # Use grouped child counts and include owners with no children. Only
  # drifted rows are written, limiting WAL and bloat when counts already agree.
  def self.run(connection)
    connection.execute(<<~SQL)
      WITH membership_counts AS (
        SELECT group_id, COUNT(*) AS memberships_count,
          COUNT(*) FILTER (WHERE accepted_at IS NULL) AS pending_memberships_count,
          COUNT(*) FILTER (WHERE admin = TRUE) AS admin_memberships_count
        FROM memberships WHERE revoked_at IS NULL GROUP BY group_id
      ), poll_counts AS (
        SELECT t.group_id, COUNT(*) AS polls_count FROM polls p
        JOIN topics t ON t.id = p.topic_id GROUP BY t.group_id
      ), discussion_counts AS (
        SELECT t.group_id, COUNT(*) AS discussions_count FROM discussions d
        JOIN topics t ON t.id = d.topic_id WHERE d.discarded_at IS NULL GROUP BY t.group_id
      ), template_counts AS (
        SELECT group_id, COUNT(*) AS poll_templates_count FROM poll_templates
        WHERE discarded_at IS NULL GROUP BY group_id
      ), organisation_members AS (
        SELECT group_id, user_id FROM memberships WHERE revoked_at IS NULL
        UNION ALL
        SELECT g.parent_id AS group_id, m.user_id FROM memberships m
        JOIN groups g ON g.id = m.group_id WHERE m.revoked_at IS NULL AND g.parent_id IS NOT NULL
      ), organisation_counts AS (
        SELECT group_id, COUNT(DISTINCT user_id) AS org_members_count
        FROM organisation_members GROUP BY group_id
      ), counts AS MATERIALIZED (
        SELECT g.id,
          COALESCE(m.memberships_count, 0) AS memberships_count,
          COALESCE(m.pending_memberships_count, 0) AS pending_memberships_count,
          COALESCE(m.admin_memberships_count, 0) AS admin_memberships_count,
          COALESCE(p.polls_count, 0) AS polls_count,
          COALESCE(d.discussions_count, 0) AS discussions_count,
          COALESCE(pt.poll_templates_count, 0) AS poll_templates_count,
          COALESCE(o.org_members_count, 0) AS org_members_count
        FROM groups g
        LEFT JOIN membership_counts m ON m.group_id = g.id
        LEFT JOIN poll_counts p ON p.group_id = g.id
        LEFT JOIN discussion_counts d ON d.group_id = g.id
        LEFT JOIN template_counts pt ON pt.group_id = g.id
        LEFT JOIN organisation_counts o ON o.group_id = g.id
      )
      #{update_changed('groups', %w[memberships_count pending_memberships_count admin_memberships_count polls_count discussions_count poll_templates_count org_members_count])}
    SQL
    connection.execute(<<~SQL)
      WITH counts AS MATERIALIZED (
        SELECT users.id, COALESCE(m.count, 0) AS memberships_count FROM users
        LEFT JOIN (SELECT user_id, COUNT(*) AS count FROM memberships WHERE revoked_at IS NULL GROUP BY user_id) m
          ON m.user_id = users.id
      )
      #{update_changed('users', %w[memberships_count])}
    SQL
    connection.execute(<<~SQL)
      WITH poll_counts AS (
        SELECT topic_id, COUNT(*) AS count FROM polls
        WHERE discarded_at IS NULL AND closed_at IS NULL AND opened_at IS NOT NULL GROUP BY topic_id
      ), reader_counts AS (
        SELECT topic_id, COUNT(*) AS count FROM topic_readers WHERE last_read_at IS NOT NULL GROUP BY topic_id
      ), counts AS MATERIALIZED (
        SELECT t.id, COALESCE(p.count, 0) AS active_polls_count, COALESCE(r.count, 0) AS seen_by_count
        FROM topics t LEFT JOIN poll_counts p ON p.topic_id = t.id LEFT JOIN reader_counts r ON r.topic_id = t.id
      )
      #{update_changed('topics', %w[active_polls_count seen_by_count])}
    SQL
    connection.execute(<<~SQL)
      WITH counts AS MATERIALIZED (
        SELECT items.id, COALESCE(children.count, 0) AS child_count
        FROM topic_items items
        LEFT JOIN (SELECT parent_id, COUNT(*) AS count FROM topic_items WHERE parent_id IS NOT NULL GROUP BY parent_id) children
          ON children.parent_id = items.id
      )
      #{update_changed('topic_items', %w[child_count])}
    SQL
    { 'discussions' => 'Discussion', 'comments' => 'Comment', 'outcomes' => 'Outcome' }.each do |table, type|
      connection.execute(<<~SQL)
        WITH counts AS MATERIALIZED (
          SELECT owners.id, COALESCE(v.count, 0) AS versions_count FROM #{table} owners
          LEFT JOIN (SELECT item_id, COUNT(*) AS count FROM versions WHERE item_type = '#{type}' GROUP BY item_id) v
            ON v.item_id = owners.id
        )
        #{update_changed(table, %w[versions_count])}
      SQL
    end
  end

  def self.update_changed(table, columns)
    assignments = columns.map { |column| "#{column} = counts.#{column}" }.join(', ')
    before = columns.map { |column| "#{table}.#{column}" }.join(', ')
    after = columns.map { |column| "counts.#{column}" }.join(', ')
    <<~SQL
      UPDATE #{table} SET #{assignments} FROM counts
      WHERE #{table}.id = counts.id AND ROW(#{before}) IS DISTINCT FROM ROW(#{after})
    SQL
  end
  private_class_method :update_changed
end
