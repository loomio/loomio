class CommentSerializer < ActiveModel::Serializer
  include Twitter::Autolink

  embed :ids, include: true
  attributes :id, :body, :created_at, :updated_at, :parent_id, :parent_author_name

  has_one :author, serializer: UserSerializer, root: 'users'
  has_one :discussion, serializer: DiscussionSerializer
  has_many :likers, serializer: UserSerializer, root: 'users'
  has_many :attachments, serializer: AttachmentSerializer, root: 'attachments'

  def parent_author_name
    object.parent.author_name if object.parent
  end

end
