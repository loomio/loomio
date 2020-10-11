class CommentSerializer < ApplicationSerializer
  attributes :id, :body, :body_format, :mentioned_usernames, :discussion_id,
             :created_at, :updated_at, :parent_id,
             :versions_count, :attachments, :author_id, :discarded_at

  has_one :author, serializer: AuthorSerializer, root: :users

  hide_when_discarded [:body]

  def include_mentioned_usernames?
    body_format == "md"
  end

  def include_secret_token?
    object.user_id == scope[:current_user_id]
  end
end
