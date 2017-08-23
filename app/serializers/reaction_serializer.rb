class ReactionSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :reaction, :reactable_id, :reactable_type
  has_one :user, serializer: UserSerializer, root: :users
  has_one :reactable, polymorphic: true
end
