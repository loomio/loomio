class DiscussionSerializer < ActiveModel::Serializer
  embed :ids, include: true

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
             :title,
             :description,
             :description_format,
             :ranges,
             :items_count,
             :last_comment_at,
             :last_activity_at,
             :closed_at,
             :seen_by_count,
             :created_at,
             :updated_at,
             :private,
             :versions_count,
             :importance,
             :pinned,
             :attachments,
             :mentioned_usernames,
             :tag_names,
             :newest_first,
             :max_depth


  attributes_from_reader :discussion_reader_id,
                         :discussion_reader_volume,
                         :last_read_at,
                         :dismissed_at,
                         :read_ranges

  has_one :author, serializer: UserSerializer, root: :users
  has_one :group, serializer: GroupSerializer, root: :groups
  has_one :guest_group, serializer: Simple::GroupSerializer, root: :groups
  has_many :active_polls, serializer: Full::PollSerializer, root: :polls
  has_one :created_event, serializer: Events::BaseSerializer, root: :events
  has_one :forked_event, serializer: Events::BaseSerializer, root: :events

  has_many :discussion_tags

  def tag_names
    object.info['tag_names'] || []
  end

  def discussion_tags
    Array(Hash(scope).dig(:tag_cache, object.id))
  end

  def active_polls
    scope[:poll_cache].get_for(object, hydrate_on_miss: false)
  end

  def include_active_polls?
    scope[:poll_cache].present?
  end

  def reader
    @reader ||= scope[:reader_cache].get_for(object) if scope[:reader_cache]
  end

  def created_event
    @created_event ||= scope[:discussion_event_cache].get_for(object, hydrate_on_miss: false).find {|event| event.kind == "new_discussion" }
  end

  def forked_event
    @forked_event ||= scope[:discussion_event_cache].get_for(object, hydrate_on_miss: false).find {|event| event.kind == "discussion_forked"}
  end

  def include_created_event?
    scope[:discussion_event_cache].present?
  end

  def include_forked_event?
    scope[:discussion_event_cache].present?
  end

  def scope
    super || {}
  end

end
