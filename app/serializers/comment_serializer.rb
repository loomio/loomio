class CommentSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :body, :body_format, :mentioned_usernames, :discussion_id,
             :created_at, :updated_at, :parent_id, :parent_author_name,
             :versions_count, :attachments, :author_id

  # has_one :author, serializer: UserSerializer, root: :users
  has_one :discussion, serializer: DiscussionSerializer
  has_many :reactions, serializer: ReactionSerializer, root: :reactions
  has_many :documents, serializer: DocumentSerializer, root: :documents

  def reactions
    scope.dig(:cache, :reactions).get_for(object)
  end

  def mentioned_usernames
    from_cache :mentions
  end

  def documents
    from_cache :documents
  end

  def include_reactions?
    scope.dig(:cache, :reactions).present?
  end

  def include_mentioned_usernames?
    from_cache(:mentions).present?
  end

  def include_documents?
    from_cache(:documents).present?
  end

  def parent_author_name
    object.parent&.author_name
  end

  private

  # pull the specified attributes from the cache passed in via serializer scope
  # This allows us to make 1 query to fetch all documents, or reactors for a series
  # of comments, rather than needing to do a separate query for each comment
  def from_cache(field)
    scope.dig(:cache, field, object.id)
  end

  def scope
    Hash(super)
  end

end
