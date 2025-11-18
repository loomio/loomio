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
             :group_id,
             :title,
             :tags,
             :content_locale,
             :description,
             :description_format,
             :discussion_template_id,
             :ranges,
             :items_count,
             :last_comment_at,
             :last_activity_at,
             :closed_at,
             :closer_id,
             :seen_by_count,
             :members_count,
             :created_at,
             :updated_at,
             :private,
             :versions_count,
             :pinned_at,
             :attachments,
             :link_previews,
             :mentioned_usernames,
             :newest_first,
             :max_depth,
             :discarded_at,
             :translation_id

  attributes_from_reader :discussion_reader_id,
                         :discussion_reader_volume,
                         :discussion_reader_user_id,
                         :last_read_at,
                         :dismissed_at,
                         :read_ranges,
                         :revoked_at,
                         :inviter_id,
                         :guest,
                         :admin

  has_one :author, serializer: AuthorSerializer, root: :users
  has_one :group, serializer: GroupSerializer, root: :groups
  has_many :active_polls, serializer: PollSerializer, root: :polls
  has_one :created_event, serializer: EventSerializer, root: :events
  has_one :forked_event, serializer: EventSerializer, root: :events
  has_one :closer, serializer: AuthorSerializer, root: :users
  has_one :translation, serializer: TranslationSerializer, root: :translations
  hide_when_discarded [:description, :title]

  def include_closer?
    object.closer_id.present?
  end

  def include_mentioned_usernames?
    description_format == "md"
  end

  def active_polls
    cache_fetch(:polls_by_discussion_id, object.id) { [] }
  end

  def reader
    return nil unless scope[:current_user_id]

    result = cache_fetch(:discussion_readers_by_discussion_id, object.id) do
      m = cache_fetch(:memberships_by_group_id, object.group_id)
      DiscussionReader.find_or_initialize_by(user_id: scope[:current_user_id], discussion_id: object.id) do |dr|
        dr.volume = (m && m.volume) || 'normal'
      end
    end

    return result if result.present?

    # record def does not exist, becasue key exists in cache and it's empty
    m = cache_fetch(:memberships_by_group_id, object.group_id)
    DiscussionReader.new(user_id: scope[:current_user_id], discussion_id: object.id, volume: (m && m.volume) || 'normal')
  end

  def created_event
    cache_fetch([:events_by_kind_and_eventable_id, 'new_discussion'], object.id) { object.created_event }
  end

  def forked_event
    cache_fetch([:events_by_kind_and_eventable_id, 'discussion_forked'], object.id) { nil }
  end
end
