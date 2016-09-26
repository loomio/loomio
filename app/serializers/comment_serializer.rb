class CommentSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :body, :mentioned_usernames, :created_at, :updated_at, :parent_id, :parent_author_name, :versions_count

  has_one :author, serializer: UserSerializer, root: :users
  has_one :discussion, serializer: DiscussionSerializer
  has_many :attachments, serializer: AttachmentSerializer, root: :attachments
  has_many :likers, serializer: UserSerializer, root: :users

  def parent_author_name
    object.parent.author_name if object.parent
  end

  def include_likers?
    Hash(scope)[:include_likers]
  end

  def include_attachments?
    Hash(scope)[:include_attachments]
  end
end
