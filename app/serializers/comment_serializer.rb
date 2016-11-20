class CommentSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :body, :mentioned_usernames, :created_at, :updated_at, :parent_id, :parent_author_name, :versions_count

  has_one :author, serializer: UserSerializer, root: :users
  has_one :discussion, serializer: DiscussionSerializer
  has_many :likers, serializer: UserSerializer, root: :users
  has_many :attachments, serializer: AttachmentSerializer, root: :attachments

  def likers
    from_cache :likers
  end

  def mentioned_usernames
    from_cache :mentions
  end

  def attachments
    from_cache :attachments
  end

  def include_likers?
    from_cache(:likers).present?
  end

  def include_mentioned_usernames?
    from_cache(:mentions).present?
  end

  def include_attachments?
    from_cache(:attachments).present?
  end

  def parent_author_name
    object.parent&.author_name
  end

  private

  # pull the specified attributes from the cache passed in via serializer scope
  # This allows us to make 1 query to fetch all attachments, or likers for a series
  # of comments, rather than needing to do a separate query for each comment
  def from_cache(field)
    Hash(scope).dig(:cache, field, object.id)
  end

end
