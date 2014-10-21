class AttachmentSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :filename, :location, :filesize, :created_at, :updated_at

  has_one :author, serializer: UserSerializer, root: 'users'
  has_one :comment, serializer: CommentSerializer, root: 'comments'

end
