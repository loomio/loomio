class AttachmentSerializer < ActiveModel::Serializer
  attributes :id, :filename, :location, :filesize, :created_at, :updated_at

  has_one :user, serializer: UserSerializer, root: 'users'
  has_one :comment, serializer: CommentSerializer, root: 'comments'

end
