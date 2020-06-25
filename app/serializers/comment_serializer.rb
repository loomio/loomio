class CommentSerializer < ApplicationSerializer
  attributes :id, :body, :body_format, :mentioned_usernames, :discussion_id,
             :created_at, :updated_at, :parent_id,
             :versions_count, :attachments, :author_id, :discarded_at

  has_one :author, serializer: AuthorSerializer, root: :users
  has_one :discussion, serializer: DiscussionSerializer, root: :discussions

  def mentioned_usernames
    from_cache :mentions
  end

  def include_mentioned_usernames?
    from_cache(:mentions).present?
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
