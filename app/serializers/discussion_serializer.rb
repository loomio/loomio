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


  def reader
    @reader ||= scope[:reader_cache].get_for(object) if scope[:reader_cache]
  end

  attributes :id,
             :key,
             :title,
             :description,
             :items_count,
             :salient_items_count,
             :first_sequence_id,
             :last_sequence_id,
             :last_comment_at,
             :last_activity_at,
             :discussion_readers_count,
             :created_at,
             :updated_at,
             :archived_at,
             :private,
             :versions_count,
             :importance,
             :pinned

  attributes_from_reader :discussion_reader_id,
                         :read_items_count,
                         :read_salient_items_count,
                         :last_read_sequence_id,
                         :discussion_reader_volume,
                         :last_read_at,
                         :dismissed_at

  has_one :author, serializer: UserSerializer, root: :users
  has_one :group, serializer: GroupSerializer, root: :groups
  has_many :active_polls, serializer: Simple::PollSerializer, root: :polls

  def active_polls
    scope[:poll_cache].get_for(object)
  end

  def include_active_polls?
    scope[:poll_cache].present?
  end

  def reader
    @reader ||= scope[:reader_cache].get_for(object) if scope[:reader_cache]
  end

  def scope
    super || {}
  end
end
