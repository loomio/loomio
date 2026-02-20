class DiscussionSerializer < ApplicationSerializer
  def self.attributes_from_reader(*attrs)
    attrs.each do |attr|
      case attr
      when :discussion_reader_id then define_method attr, -> { reader.id }
      else                            define_method attr, -> { reader.send(attr) }
      end
      define_method :"include_#{attr}?", -> { reader.present? }
    end
    attributes *attrs
  end

  attributes :id,
             :key,
             :topic_id,
             :title,
             :tags,
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
  has_one :created_event, serializer: EventSerializer, root: :events
  has_one :forked_event, serializer: EventSerializer, root: :events
  has_one :translation, serializer: TranslationSerializer, root: :translations
  hide_when_discarded [:description, :title]

  def include_mentioned_usernames?
    description_format == "md"
  end

  def created_event
    cache_fetch([:events_by_kind_and_eventable_id, 'new_discussion'], object.id) { object.created_event }
  end

  def forked_event
    cache_fetch([:events_by_kind_and_eventable_id, 'discussion_forked'], object.id) { nil }
  end
end
