class TopicSerializer < ApplicationSerializer
  attributes :id,
             :items_count,
             :ranges,
             :max_depth,
             :newest_first,
             :last_activity_at,
             :closed_at,
             :closer_id,
             :pinned_at,
             :topicable_id,
             :topicable_type,
             :members_count,
             :anonymous_polls_count,
             :closed_polls_count,
             :seen_by_count

  # Reader attributes
  attributes :topic_reader_id,
             :reader_volume,
             :last_read_at,
             :dismissed_at,
             :read_ranges,
             :reader_inviter_id,
             :reader_guest,
             :reader_admin

  def ranges
    object.ranges || []
  end

  # def active_polls
  #   cache_fetch(:polls_by_topic_id, object.topic_id) { [] }
  # end

  def reader
    return @reader if defined?(@reader)
    return @reader = nil unless scope[:current_user_id]

    @reader = cache_fetch(:topic_readers_by_topic_id, object.id) do
      group_id = object.topicable.try(:group_id)
      m = group_id && cache_fetch(:memberships_by_group_id, group_id)
      TopicReader.find_or_initialize_by(user_id: scope[:current_user_id], topic_id: object.id) do |tr|
        tr.volume = (m && m.volume) || 'normal'
      end
    end

    return @reader if @reader.present?

    group_id = object.topicable.try(:group_id)
    m = group_id && cache_fetch(:memberships_by_group_id, group_id)
    @reader = TopicReader.new(user_id: scope[:current_user_id], topic_id: object.id, volume: (m && m.volume) || 'normal')
  end

  def topic_reader_id
    reader&.id
  end

  def include_topic_reader_id?
    reader.present? && reader.persisted?
  end

  def reader_volume
    reader&.volume
  end

  def include_reader_volume?
    reader.present?
  end

  def last_read_at
    reader&.last_read_at
  end

  def include_last_read_at?
    reader.present?
  end

  def dismissed_at
    reader&.dismissed_at
  end

  def include_dismissed_at?
    reader.present?
  end

  def read_ranges
    reader&.read_ranges
  end

  def include_read_ranges?
    reader.present?
  end

  def reader_inviter_id
    reader&.inviter_id
  end

  def include_reader_inviter_id?
    reader.present?
  end

  def reader_guest
    reader&.guest
  end

  def include_reader_guest?
    reader.present?
  end

  def reader_admin
    reader&.admin
  end

  def include_reader_admin?
    reader.present?
  end
end
