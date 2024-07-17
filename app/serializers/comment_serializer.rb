class CommentSerializer < ApplicationSerializer
  attributes :id,
             :body,
             :body_format,
             :mentioned_usernames,
             :discussion_id,
             :created_at,
             :updated_at,
             :parent_id,
             :parent_type,
             :content_locale,
             :versions_count,
             :attachments,
             :link_previews,
             :author_id,
             :discarded_at

  has_one :author, serializer: AuthorSerializer, root: :users
  has_one :discussion, serializer: DiscussionSerializer, root: :discussions
  

  hide_when_discarded [:body]

  def include_mentioned_usernames?
    body_format == "md"
  end
end
