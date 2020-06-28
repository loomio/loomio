class CommentSerializer < ApplicationSerializer
  attributes :id, :body, :body_format, :mentioned_usernames, :discussion_id,
             :created_at, :updated_at, :parent_id,
             :versions_count, :attachments, :author_id, :discarded_at

  has_one :author, serializer: AuthorSerializer, root: :users
  has_one :discussion, serializer: DiscussionSerializer, root: :discussions

  def include_mentioned_usernames?
    body_format == "md"
  end
end
