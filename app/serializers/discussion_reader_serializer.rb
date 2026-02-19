class DiscussionReaderSerializer < ApplicationSerializer
  attributes :id,
             :user_id,
             :topic_id,
             :discussion_id,
             :read_ranges,
             :last_read_at,
             :dismissed_at,
             :volume,
             :inviter_id,
             :guest,
             :admin,
             :revoked_at

  has_one :user, serializer: AuthorSerializer, root: :users

  def discussion_id
    object.discussion_id
  end

  def last_read_at
    topicable = object.topic&.topicable
    if topicable.is_a?(Discussion) && topicable.anonymous_polls_count > 0
      nil
    else
      object.last_read_at
    end
  end

  def read_ranges
    topicable = object.topic&.topicable
    if topicable.is_a?(Discussion) && topicable.anonymous_polls_count > 0
      []
    else
      object.read_ranges
    end
  end

  def volume
    object[:volume]
  end
end
