class TopicReaderSerializer < ApplicationSerializer
  attributes :id,
             :user_id,
             :topic_id,
             :read_ranges,
             :last_read_at,
             :dismissed_at,
             :volume_email,
             :volume_push,
             :inviter_id,
             :guest,
             :admin,
             :revoked_at

  has_one :user, serializer: AuthorSerializer, root: :users

  def last_read_at
    if object.topic.anonymous_polls_count.positive?
      nil
    else
      object.last_read_at
    end
  end

  def read_ranges
    if object.topic.anonymous_polls_count.positive?
      []
    else
      object.read_ranges
    end
  end

end
