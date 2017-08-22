class ReactionSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :reaction
  has_one :user, serializer: UserSerializer, root: :users
  has_one :reactable, polymorphic: true
end
