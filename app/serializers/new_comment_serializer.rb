class NewCommentSerializer < ActiveModel::Serializer
  attributes :id, :sequence_id, :kind
  has_one :comment, serializer: CommentSerializer
end
