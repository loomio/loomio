class RecordCountRepairService
  COLUMNS = {
    'groups' => %w[memberships_count pending_memberships_count admin_memberships_count polls_count discussions_count poll_templates_count org_members_count],
    'users' => %w[memberships_count],
    'topics' => %w[active_polls_count seen_by_count],
    'topic_items' => %w[child_count],
    'discussions' => %w[versions_count],
    'comments' => %w[versions_count],
    'outcomes' => %w[versions_count]
  }.freeze
  VERSION_TYPES = { 'discussions' => 'Discussion', 'comments' => 'Comment', 'outcomes' => 'Outcome' }.freeze

  def self.run(**options, &progress)
    new(**options).run(&progress)
  end

  def initialize(tables: COLUMNS.keys, batch_size: 100, pause_seconds: 0.1,
                 statement_timeout_ms: 1_000, after_id: 0, limit: nil, dry_run: false)
    raise ArgumentError, 'tables must name retained count owners' if tables.empty? || (tables - COLUMNS.keys).any?
    raise ArgumentError, 'batch_size must be between 1 and 1000' unless (1..1_000).cover?(batch_size)
    raise ArgumentError, 'pause_seconds must be finite and nonnegative' unless pause_seconds.finite? && pause_seconds >= 0
    raise ArgumentError, 'statement_timeout_ms must be positive' unless statement_timeout_ms.positive?
    raise ArgumentError, 'after_id must be nonnegative' if after_id.negative?
    raise ArgumentError, 'limit must be positive' if limit && !limit.positive?
    raise ArgumentError, 'after_id and limit require a single table' if tables.size != 1 && (after_id.positive? || limit)

    @tables = tables
    @batch_size = batch_size
    @pause_seconds = pause_seconds
    @statement_timeout_ms = statement_timeout_ms
    @after_id = after_id
    @limit = limit
    @dry_run = dry_run
  end

  # Run only after the transactional count writers have been deployed. Lock
  # owners before taking a fresh READ COMMITTED snapshot of their children, so
  # a concurrent delta cannot be overwritten by a stale recount. SKIP LOCKED
  # avoids waiting on active writers; query timeouts bound the work while our
  # row locks are held. Each batch commits before progress reporting or sleep.
  # New records beyond the initial maximum already use the new callbacks.
  def run
    connection = ActiveRecord::Base.connection
    raise ArgumentError, 'count repair must run outside a transaction' if connection.transaction_open?

    @tables.to_h do |table|
      started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      maximum_id = connection.select_value("SELECT MAX(id) FROM #{table}") || 0
      stats = { checked: 0, drifted: 0, updated: 0, deferred: 0, after_id: @after_id,
                finished: false, elapsed_seconds: 0.0, batch_seconds_max: 0.0 }
      loop do
        batch_size = @limit ? [@batch_size, @limit - stats[:checked]].min : @batch_size
        break if batch_size.zero?

        ids = connection.select_values(<<~SQL)
          SELECT id FROM #{table}
          WHERE id > #{stats[:after_id]} AND id <= #{maximum_id}
          ORDER BY id LIMIT #{batch_size}
        SQL
        if ids.empty?
          stats[:finished] = true
          stats[:elapsed_seconds] = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at).round(3)
          yield table, stats.dup if block_given?
          break
        end

        batch_started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        result = repair_batch(connection, table, ids)
        batch_seconds = Process.clock_gettime(Process::CLOCK_MONOTONIC) - batch_started_at
        stats[:batch_seconds_max] = [stats[:batch_seconds_max], batch_seconds.round(3)].max
        %i[drifted updated deferred].each { |key| stats[key] += result.fetch(key) }
        stats[:checked] += ids.size
        stats[:after_id] = ids.last
        stats[:finished] = ids.last == maximum_id
        stats[:elapsed_seconds] = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at).round(3)
        yield table, stats.dup if block_given?
        break if stats[:finished] || (@limit && stats[:checked] == @limit)

        sleep @pause_seconds
      end
      [table, stats]
    end
  end

  private

  def repair_batch(connection, table, ids)
    connection.transaction(isolation: :read_committed) do
      connection.execute("SET LOCAL statement_timeout = #{@statement_timeout_ms}")
      connection.execute("SET LOCAL lock_timeout = '100ms'")
      locked_ids = if @dry_run
        ids
      else
        # Cached locking reads would acquire no locks. exec_query always runs
        # the statement and clears reads cached before this batch.
        connection.exec_query(<<~SQL).rows.map(&:first)
          SELECT id FROM #{table} WHERE id IN (#{ids.join(',')})
          ORDER BY id FOR NO KEY UPDATE SKIP LOCKED
        SQL
      end
      changed = 0
      unless locked_ids.empty?
        columns = COLUMNS.fetch(table)
        before = columns.map { |column| "#{table}.#{column}" }.join(', ')
        after = columns.map { |column| "counts.#{column}" }.join(', ')
        comparison = "#{table}.id = counts.id AND ROW(#{before}) IS DISTINCT FROM ROW(#{after})"
        counts = "WITH counts AS MATERIALIZED (#{counts_sql(table, locked_ids)})"
        changed = if @dry_run
          connection.exec_query("#{counts} SELECT COUNT(*) FROM #{table}, counts WHERE #{comparison}").rows.first.first
        else
          assignments = columns.map { |column| "#{column} = counts.#{column}" }.join(', ')
          connection.exec_update("#{counts} UPDATE #{table} SET #{assignments} FROM counts WHERE #{comparison}")
        end
      end
      { drifted: changed, updated: @dry_run ? 0 : changed, deferred: ids.size - locked_ids.size }
    end
  rescue ActiveRecord::QueryCanceled, ActiveRecord::LockWaitTimeout, ActiveRecord::Deadlocked
    # Roll back the whole batch, release its locks, and let operators retry the
    # reported table later with a smaller batch or a longer query timeout.
    { drifted: 0, updated: 0, deferred: ids.size }
  end

  # Every child lookup is restricted to these owners and uses their existing
  # foreign-key indexes. A large individual owner can still exceed the timeout;
  # it is deferred rather than extending the lock window indefinitely.
  def counts_sql(table, ids)
    values = case table
    when 'groups'
      <<~SQL
        m.memberships_count, m.pending_memberships_count, m.admin_memberships_count,
        (SELECT COUNT(*) FROM polls p JOIN topics t ON t.id = p.topic_id
         WHERE t.group_id = owners.id) AS polls_count,
        (SELECT COUNT(*) FROM discussions d JOIN topics t ON t.id = d.topic_id
         WHERE t.group_id = owners.id AND d.discarded_at IS NULL) AS discussions_count,
        (SELECT COUNT(*) FROM poll_templates pt
         WHERE pt.group_id = owners.id AND pt.discarded_at IS NULL) AS poll_templates_count,
        (SELECT COUNT(DISTINCT user_id) FROM memberships
         WHERE revoked_at IS NULL AND group_id IN (
           SELECT id FROM groups WHERE id = owners.id OR parent_id = owners.id
         )) AS org_members_count
      SQL
    when 'users'
      '(SELECT COUNT(*) FROM memberships WHERE user_id = owners.id AND revoked_at IS NULL) AS memberships_count'
    when 'topics'
      <<~SQL
        (SELECT COUNT(*) FROM polls WHERE topic_id = owners.id AND discarded_at IS NULL
         AND closed_at IS NULL AND opened_at IS NOT NULL) AS active_polls_count,
        (SELECT COUNT(*) FROM topic_readers WHERE topic_id = owners.id AND last_read_at IS NOT NULL) AS seen_by_count
      SQL
    when 'topic_items'
      '(SELECT COUNT(*) FROM topic_items children WHERE children.parent_id = owners.id) AS child_count'
    else
      "(SELECT COUNT(*) FROM versions WHERE item_type = '#{VERSION_TYPES.fetch(table)}' AND item_id = owners.id) AS versions_count"
    end
    memberships = if table == 'groups'
      <<~SQL
        LEFT JOIN LATERAL (
          SELECT COUNT(*) AS memberships_count,
            COUNT(*) FILTER (WHERE accepted_at IS NULL) AS pending_memberships_count,
            COUNT(*) FILTER (WHERE admin = TRUE) AS admin_memberships_count
          FROM memberships WHERE group_id = owners.id AND revoked_at IS NULL
        ) m ON TRUE
      SQL
    end
    "SELECT owners.id, #{values} FROM #{table} owners #{memberships} WHERE owners.id IN (#{ids.join(',')})"
  end
end
