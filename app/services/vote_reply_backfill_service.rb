class VoteReplyBackfillService
  def initialize(before_id: nil, batch_size: 500, statement_timeout_ms: 5_000)
    raise ArgumentError, 'before_id must be positive' if before_id && !before_id.positive?
    raise ArgumentError, 'batch_size must be between 1 and 1000' unless (1..1_000).cover?(batch_size)
    raise ArgumentError, 'statement_timeout_ms must be positive' unless statement_timeout_ms.positive?

    @before_id, @batch_size, @statement_timeout_ms = before_id, batch_size, statement_timeout_ms
  end

  # Bound discovery by timeline IDs before joining comments and votes. Scanning
  # newest first avoids an unbounded search through sparse historical matches.
  # Each topic commits separately; a retried batch skips already repaired trees.
  def run_batch
    connection = ActiveRecord::Base.connection
    raise ArgumentError, 'vote reply backfill must run outside a transaction' if connection.transaction_open?

    ids, topic_ids = with_timeouts do
      scope = TopicItem.all
      scope = scope.where('id < ?', @before_id) if @before_id
      ids = scope.order(id: :desc).limit(@batch_size).pluck(:id)
      [ids, affected_replies(ids).distinct.pluck(:topic_id)]
    end

    repaired = 0
    topic_ids.sort.each do |topic_id|
      with_timeouts do
        Topic.where(id: topic_id).with_write_lock(:id) do |locked_ids|
          next if locked_ids.empty?
          # A live write, deletion, or another repair may have won the lock.
          next unless affected_replies(ids).where(topic_id: topic_id).exists?

          TopicService.repair(topic_id)
          repaired += 1
        end
      end
    end
    { before_id: ids.last || @before_id, checked: ids.size, repaired: repaired, finished: ids.size < @batch_size }
  end

  private

  def with_timeouts
    ActiveRecord::Base.transaction do
      connection = ActiveRecord::Base.connection
      connection.execute("SET LOCAL lock_timeout = '100ms'")
      connection.execute("SET LOCAL statement_timeout = '#{@statement_timeout_ms.to_i}ms'")
      yield
    end
  end

  # Comment#parent still identifies the vote even when the timeline occurrence
  # fell back to the thread root. Match its first visible vote item, and respect
  # the depth cap where replies intentionally become siblings of their parent.
  def affected_replies(ids)
    TopicItem.where(id: ids, kind: 'new_comment', itemable_type: 'Comment')
      .joins("INNER JOIN comments replies ON replies.id = topic_items.itemable_id AND replies.parent_type = 'Stance'")
      .joins('INNER JOIN stances votes ON votes.id = replies.parent_id')
      .joins('INNER JOIN polls ON polls.id = votes.poll_id AND polls.topic_id = topic_items.topic_id')
      .joins('INNER JOIN topics ON topics.id = topic_items.topic_id')
      .joins(<<~SQL.squish)
        INNER JOIN LATERAL (
          SELECT id, kind, parent_id, depth FROM topic_items vote_items
          WHERE vote_items.itemable_type = 'Stance' AND vote_items.itemable_id = votes.id
            AND vote_items.topic_id = topic_items.topic_id
            AND vote_items.kind IN ('stance_created', 'stance_updated')
          ORDER BY id LIMIT 1
        ) vote_item ON vote_item.kind = 'stance_updated'
      SQL
      .where(<<~SQL.squish)
        topic_items.parent_id IS DISTINCT FROM
          CASE WHEN topics.max_depth = vote_item.depth THEN vote_item.parent_id ELSE vote_item.id END
      SQL
  end
end
