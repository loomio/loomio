class CommentSerializer < ApplicationSerializer
  attributes :id,
             :body,
             :body_format,
             :mentioned_usernames,
             :topic_id,
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

  hide_when_discarded [:body]

  def discussion_id
    topic = object.topic
    topic&.topicable_type == 'Discussion' ? topic.topicable_id : nil
  end

  def include_mentioned_usernames?
    body_format == "md"
  end
end
