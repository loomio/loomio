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
    if anonymous_polls?
      nil
    else
      object.last_read_at
    end
  end

  def read_ranges
    if anonymous_polls?
      []
    else
      object.read_ranges
    end
  end

  private

  def anonymous_polls?
    @anonymous_polls ||= cache_fetch(:anonymous_polls_counts_by_topic_id, object.topic_id) do
      object.topic.anonymous_polls_count
    end
    @anonymous_polls.positive?
  end

end
