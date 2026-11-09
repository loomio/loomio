class RecordCache::Loader
  attr_reader :cache, :records

  def initialize(cache:, records:)
    @cache = cache
    @records = records
  end

  def load
    raise NotImplementedError
  end

  private

  def current_user_id
    cache.current_user_id
  end

  def add_topic_readers(topic_ids)
    cache.add_topic_readers(
      TopicReader.where(topic_id: topic_ids, user_id: current_user_id),
      topic_ids: topic_ids
    )
  end

  def add_groups(group_ids, memberships: true, records: nil)
    cache.load_groups(group_ids, memberships: memberships, records: records)
  end
end
