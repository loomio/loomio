class AttachmentSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :filename, :location, :filesize, :created_at

  has_one :comment, serializer: CommentSerializer

end
