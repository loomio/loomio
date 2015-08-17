class DiscussionSerializer < ActiveModel::Serializer

  def self.attributes_from_reader(*attrs)
    attrs.each do |attr|
      define_method attr,                 -> { reader.send(attr) if has_valid_reader? }
      define_method :"#{attr}_included?", -> { has_valid_reader? }
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

  attributes_from_reader :last_read_at,
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
    @reader ||= DiscussionReader.for(user: scope[:user], discussion: object)
  end

  def has_valid_reader?
    @has_valid_reader ||= reader.present? && reader.user.present?
  end

end
