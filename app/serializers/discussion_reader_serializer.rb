class DiscussionReaderSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id,
             :discussion_reader_id,
             :ranges_string,
             :read_ranges_string,
             :last_read_at,
             :seen_by_count,
             :volume,
             :dismissed_at

  has_one :created_event, serializer: Events::BaseSerializer, root: :events

  def created_event
    object.discussion.created_event
  end

  def id
    object.discussion_id
  end

  def ranges_string
    object.discussion.ranges_string
  end

  def discussion_reader_id
    object.id
  end

  def seen_by_count
    object.discussion.seen_by_count
  end
end
