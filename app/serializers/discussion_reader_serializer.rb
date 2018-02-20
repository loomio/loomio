class DiscussionReaderSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id,
             :key,
             :discussion_reader_id,
             :ranges,
             :read_ranges,
             :last_read_at,
             :seen_by_count,
             :discussion_reader_volume,
             :dismissed_at

  has_one :created_event, serializer: Events::BaseSerializer, root: :events

  def created_event
    object.discussion.created_event
  end

  def key
    object.discussion.key
  end

  def id
    object.discussion_id
  end

  def ranges
    object.discussion.ranges
  end

  def discussion_reader_id
    object.id
  end

  def discussion_reader_volume
    object.volume
  end

  def seen_by_count
    object.discussion.seen_by_count
  end
end
