class ReactionSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :reaction
  has_one :user
  has_one :reactable
end
