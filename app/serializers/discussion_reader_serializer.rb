class DiscussionReaderSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id,
             :user_id,
             :discussion_id,
             :read_ranges,
             :last_read_at,
             :dismissed_at,
             :volume,
             :inviter_id,
             :admin,
             :revoked_at,
             :last_read_at


  has_one :user, serializer: AuthorSerializer, root: :users
  has_one :discussion, serializer: DiscussionSerializer, root: :discussions

  def volume
    object[:volume]
  end
end
