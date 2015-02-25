class AttachmentSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :filename, :location, :filesize, :created_at, :is_an_image?

  has_one :comment, serializer: CommentSerializer
  has_one :author, serializer: UserSerializer, root: 'users'
end
