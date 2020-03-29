class DiscussionReaderSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id,
             :discussion_id,
             :read_ranges,
             :last_read_at,
             :dismissed_at,
             :volume

  has_one :user, serializer: UserSerializer, root: :users
end
