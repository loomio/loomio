class CommentSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :body, :mentioned_usernames, :created_at, :updated_at, :parent_id, :parent_author_name, :versions_count

  has_one :author, serializer: UserSerializer, root: :users
  has_one :discussion, serializer: DiscussionSerializer

  def parent_author_name
    object.parent.author_name if object.parent
  end
end
