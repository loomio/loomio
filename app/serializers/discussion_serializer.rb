class DiscussionSerializer < ApplicationSerializer
  attributes :id,
             :key,
             :group_id,
             :topic_id,
             :title,
             :content_locale,
             :description,
             :description_format,
             :discussion_template_id,
             :created_at,
             :updated_at,
             :versions_count,
             :attachments,
             :link_previews,
             :mentioned_usernames,
             :discarded_at,
             :translation_id

  has_one :topic, serializer: TopicSerializer, root: :topics
  has_one :author, serializer: AuthorSerializer, root: :users
  has_one :translation, serializer: TranslationSerializer, root: :translations
  hide_when_discarded [:description, :title]

  def group_id
    topic&.group_id
  end

  def include_mentioned_usernames?
    description_format == "md"
  end

end
