class CommentSerializer < ApplicationSerializer
  attributes :id,
             :body,
             :body_format,
             :mentioned_usernames,
             :topic_id,
             :created_at,
             :updated_at,
             :parent_id,
             :parent_type,
             :content_locale,
             :versions_count,
             :attachments,
             :link_previews,
             :author_id,
             :discarded_at,
             :discarded_by

  has_one :author, serializer: AuthorSerializer, root: :users
  has_many :reactions, serializer: ReactionSerializer, root: :reactions

  hide_when_discarded [:body]

  def include_mentioned_usernames?
    body_format == "md"
  end
end
