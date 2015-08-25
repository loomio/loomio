class DiscussionSerializer < ActiveModel::Serializer

  def self.attributes_from_reader(*attrs)
    attrs.each do |attr|
      case attr
      when :discussion_reader_id then define_method attr, -> { reader.try(:id) }
      else                            define_method attr, -> { reader.try(attr) }
      end
      define_method :"#{attr}_included?", -> { reader.present? }
    end
    attributes *attrs
  end

  embed :ids, include: true
  attributes :id,
             :key,
             :title,
             :description,
             :last_item_at,
             :last_comment_at,
             :last_activity_at,
             :created_at,
             :updated_at,
             :items_count,
             :salient_items_count,
             :comments_count,
             :private,
             :archived_at,
             :created_at,
             :updated_at,
             :first_sequence_id,
             :last_sequence_id

  attributes_from_reader :discussion_reader_id,
                         :last_read_at,
                         :read_comments_count,
                         :read_items_count,
                         :read_salient_items_count,
                         :last_read_sequence_id,
                         :volume,
                         :participating,
                         :starred

  has_one :author, serializer: UserSerializer, root: 'users'
  has_one :group, serializer: GroupSerializer, root: 'groups'
  has_one :active_proposal, serializer: MotionSerializer, root: 'proposals'

  def author
    object.author
  end

  def active_proposal
    object.current_motion
  end

  def filter(keys)
    keys.delete(:active_proposal) unless object.current_motion.present?
    keys
  end

  def scope
    super || {}
  end

  def reader
    @reader ||= scope[:reader_cache].get_for(object) if scope[:reader_cache]
  end

end
