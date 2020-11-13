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
             :description,
             :description_format,
             :ranges,
             :items_count,
             :last_comment_at,
             :last_activity_at,
             :closed_at,
             :seen_by_count,
             :members_count,
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
             :max_depth,
             :discarded_at,
             :secret_token


  attributes_from_reader :discussion_reader_id,
                         :discussion_reader_volume,
                         :last_read_at,
                         :dismissed_at,
                         :read_ranges,
                         :revoked_at,
                         :inviter_id,
                         :admin

  has_one :author, serializer: AuthorSerializer, root: :users
  # has_one :group, serializer: GroupSerializer, root: :groups
  has_many :active_polls, serializer: PollSerializer, root: :polls
  has_one :created_event, serializer: Events::BaseSerializer, root: :events
  has_one :forked_event, serializer: Events::BaseSerializer, root: :events
  #
  # has_many :discussion_tags
  hide_when_discarded [:description, :title]

  def include_group?
    object.group_id
  end

  def tag_names
    object.info['tag_names'] || []
  end

  def discussion_tags
    Array(Hash(scope).dig(:tag_cache, object.id))
  end

  def include_mentioned_usernames?
    description_format == "md"
  end

  def active_polls
    scope_fetch(:polls_by_discussion_id, object.id) do
      []
    end
  end

  def reader
    scope_fetch(:discussion_readers_by_discussion_id, object.id) do
      DiscussionReader.new(discussion: object)
    end
  end

  def created_event
    scope_fetch([:events_by_discussion_id, 'new_discussion'], object.id)
  end

  def forked_event
    scope_fetch([:events_by_discussion_id, 'discussion_forked'], object.id) { nil }
  end
end
