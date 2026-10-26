class ItemTagBackfillService
  TABLES = { 'summaries' => 'topics', 'search' => 'pg_search_documents' }.freeze

  def initialize(phase: 'summaries', after_id: 0, through_id: nil, batch_size: 500, statement_timeout_ms: 1_000)
    raise ArgumentError, 'unknown tag backfill phase' unless TABLES.key?(phase)
    raise ArgumentError, 'after_id must be nonnegative' if after_id.negative?
    raise ArgumentError, 'through_id must be nonnegative' if through_id && through_id.negative?
    raise ArgumentError, 'batch_size must be between 1 and 1000' unless (1..1_000).cover?(batch_size)
    raise ArgumentError, 'statement_timeout_ms must be positive' unless statement_timeout_ms.positive?

    @phase, @after_id, @through_id = phase, after_id, through_id
    @batch_size, @statement_timeout_ms = batch_size, statement_timeout_ms
  end

  # Every call commits one bounded batch. Lock owners before reading their tag
  # assignments, matching live tag writers, so a stale snapshot cannot overwrite
  # an edit that committed while the backfill was waiting for a row lock.
  def run_batch
    connection = ActiveRecord::Base.connection
    raise ArgumentError, 'tag backfill must run outside a transaction' if connection.transaction_open?

    table = TABLES.fetch(@phase)
    through_id = @through_id || connection.select_value("SELECT MAX(id) FROM #{table}") || 0
    result = { phase: @phase, after_id: @after_id, through_id: through_id, checked: 0, updated: 0, finished: true }
    connection.transaction do
      connection.execute("SET LOCAL lock_timeout = '100ms'")
      connection.execute("SET LOCAL statement_timeout = #{@statement_timeout_ms}")
      # Keep GIN pending-list cleanup small enough for bounded search updates.
      # The default 4MB list can force a multi-second flush inside one UPDATE.
      connection.execute("SET LOCAL gin_pending_list_limit = '64kB'") if @phase == 'search'
      ids = connection.select_values(<<~SQL)
        SELECT id FROM #{table}
        WHERE id > #{@after_id} AND id <= #{through_id}
        ORDER BY id LIMIT #{@batch_size}
        FOR NO KEY UPDATE
      SQL
      unless ids.empty?
        updated = @phase == 'summaries' ? update_summaries(connection, ids) : update_search(connection, ids)
        result.merge!(after_id: ids.last, checked: ids.size, updated: updated, finished: ids.last >= through_id)
      end
    end
    result
  end

  private

  def update_summaries(connection, ids)
    rows = TopicItem.tags_visible.where(topic_id: ids).where('cardinality(tags) > 0')
      .pluck(:topic_id, :sequence_id, :tags).group_by(&:first)
    summaries = ids.map do |id|
      assignments = rows.fetch(id, [])
      { id: id, tags: TagService.clean_tag_names(assignments.flat_map(&:last)),
        has_tagged_replies: assignments.any? { |row| row[1] && row[1] > 0 } }
    end
    bind = ActiveRecord::Relation::QueryAttribute.new('summaries', summaries.to_json, ActiveRecord::Type::String.new)
    connection.exec_update(<<~SQL, 'Backfill topic tag summaries', [bind])
      WITH desired AS (
        SELECT id, ARRAY(SELECT jsonb_array_elements_text(tags))::varchar[] AS tags, has_tagged_replies
        FROM jsonb_to_recordset($1::jsonb) AS records(id bigint, tags jsonb, has_tagged_replies boolean)
      )
      UPDATE topics SET tags = desired.tags, has_tagged_replies = desired.has_tagged_replies
      FROM desired WHERE topics.id = desired.id
        AND ROW(topics.tags, topics.has_tagged_replies) IS DISTINCT FROM ROW(desired.tags, desired.has_tagged_replies)
    SQL
  end

  # Preserve searchable text and timestamps. Use the same kept-contribution
  # rules as live indexing; votes and orphaned/deleted contributions get no tags.
  def update_search(connection, ids)
    documents = PgSearch::Document.arel_table
    assignment = TopicItem.tags_visible
      .where('cardinality(topic_items.tags) > 0')
      .where(TopicItem.arel_table[:itemable_type].eq(documents[:searchable_type]))
      .where(TopicItem.arel_table[:itemable_id].eq(documents[:searchable_id]))
      .select(:tags).order(:id).limit(1).to_sql
    connection.exec_update(<<~SQL, 'Backfill search document tags')
      WITH desired AS MATERIALIZED (
        SELECT id, COALESCE((#{assignment}), ARRAY[]::varchar[]) AS tags
        FROM pg_search_documents WHERE id IN (#{ids.join(',')})
      )
      UPDATE pg_search_documents SET tags = desired.tags
      FROM desired WHERE pg_search_documents.id = desired.id
        AND pg_search_documents.tags IS DISTINCT FROM desired.tags
    SQL
  end
end
