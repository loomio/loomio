class DiscussionReaderSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id,
             :discussion_id,
             :read_ranges,
             :last_read_at,
             :dismissed_at,
             :volume,
             :inviter_id,
             :admin,
             :revoked_at

  has_one :user, serializer: UserSerializer, root: :users

  def volume
    object[:volume]
  end
end
