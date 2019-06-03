class ReactionSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :reaction, :reactable_id, :reactable_type, :user_id
  # has_one :user, serializer: UserSerializer, root: :users
end
