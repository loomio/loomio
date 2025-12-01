class DiscussionReaderSerializer < ApplicationSerializer
  attributes :id,
             :user_id,
             :discussion_id,
             :read_ranges,
             :last_read_at,
             :dismissed_at,
             :volume,
             :email_volume,
             :push_volume,
             :inviter_id,
             :guest,
             :admin,
             :revoked_at

  has_one :user, serializer: AuthorSerializer, root: :users
  # has_one :discussion, serializer: DiscussionSerializer, root: :discussions

  def last_read_at
    object.discussion.anonymous_polls_count == 0 ? object.last_read_at : nil
  end

  def read_ranges
    object.discussion.anonymous_polls_count == 0 ? object.read_ranges : []
  end

  def volume
    object[:email_volume]
  end
  
  def email_volume
    object[:email_volume]
  end
  
  def push_volume
    object[:push_volume]
  end
end
