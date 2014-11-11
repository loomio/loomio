class CommentVoteSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id
  has_one :user
  has_one :comment
end
