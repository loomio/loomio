class TopicItem < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  include CustomCounterCache::Model
  include PrettyUrlHelper

  belongs_to :itemable, polymorphic: true
  belongs_to :topic
  belongs_to :user, required: false
  belongs_to :parent, class_name: "TopicItem", required: false
  has_many :children, class_name: "TopicItem", foreign_key: :parent_id
  has_many :notifications, as: :subject, dependent: :destroy
  before_validation :set_kind, :set_itemable_version_id, :set_topic, :set_user_from_itemable, on: :create
  before_create :set_parent_and_depth
  before_create :set_sequences
  after_rollback :reset_sequences
  before_destroy :reparent_children
  before_destroy :reset_sequences

  after_create  :update_sequence_info!
  after_create  :mark_actor_as_read!
  after_destroy :update_sequence_info!

  define_counter_cache(:child_count) { |topic_item| topic_item.children.count }
  update_counter_cache :parent, :child_count

  before_save :sync_itemable_foreign_key

  scope :unreadable, -> { where.not(kind: 'discussion_closed') }

  delegate :group, to: :itemable, allow_nil: true
  delegate :poll, to: :itemable, allow_nil: true
  delegate :groups, to: :itemable, allow_nil: true
  delegate :update_sequence_info!, to: :topic

  # A topic item's actor should not acquire unread state for their own action.
  def mark_actor_as_read!
    reader = actor
    return unless reader&.is_logged_in?
    return unless sequence_id

    TopicReader.for(topic: topic, user: reader)
               .update_reader(ranges: sequence_id, volume_email: :loud)
  end
  private :mark_actor_as_read!

  def user
    super || AnonymousUser.new
  end

  def actor
    user
  end

  def actor_id
    user_id
  end

  def notification_url
    model = case kind
            when 'stance_created' then itemable.poll
            else itemable
            end
    return discussion_path(topic.discussion, sequence_id: sequence_id) if topic&.discussion

    polymorphic_path(model)
  end

  def set_parent_and_depth
    return if position_key.present? # Skip if already set (e.g., cloned topic_items)
    self.parent = max_depth_adjusted_parent
    self.depth = parent ? parent.depth + 1 : 0
  end

  def set_parent_and_depth!
    set_parent_and_depth
    update_columns(parent_id: parent_id, depth: depth)
  end

  def set_sequences
    if parent_id
      return if sequence_id.present? # Skip if already set (e.g., cloned topic_items)
      self.sequence_id = next_sequence_id!
      self.position = next_position!
      self.position_key = [parent&.position_key, TopicItem.zero_fill(position)].compact.join('-')
    elsif root_topic_item?
      self.sequence_id = 0
      self.position = 0
      self.position_key = TopicItem.zero_fill(0)
    end
  end

  def root_topic_item?
    return true if kind == 'new_discussion'
    if kind == 'poll_created' && itemable&.topic&.topicable == itemable
      created_topic_item = itemable.created_topic_item
      return true if created_topic_item.nil? || created_topic_item == self
    end
    false
  end

  def set_sequence_id!
    update_attribute(:sequence_id, next_sequence_id!)
  end

  def reset_sequences
    SequenceService.drop_seq!('topic_sequence_id', topic_id)
    TopicService.reset_child_positions(parent.id, parent.position_key) if parent_id && parent
  end

  def reparent_children
    TopicItem.where(parent_id: id).update_all(parent_id: parent_id, depth: depth) if parent_id
  end

  def next_sequence_id!
    unless SequenceService.seq_present?('topic_sequence_id', topic_id)
      val = TopicItem.
            where(topic_id: topic_id).
            where("sequence_id is not null").
            order(sequence_id: :desc).
            limit(1).pluck(:sequence_id).last || 0
      SequenceService.create_seq!('topic_sequence_id', topic_id, val)
    end
    SequenceService.next_seq!('topic_sequence_id', topic_id)
  end

  def next_position!
    return 0 unless parent_id
    unless SequenceService.seq_present?('events_position', parent_id)
      val = TopicItem.where(parent_id: parent_id,
                       topic_id: topic_id).
                       order(position: :desc).
                       limit(1).pluck(:position).last || 0
      SequenceService.create_seq!('events_position', parent_id, val)
    end
    SequenceService.next_seq!('events_position', parent_id)
  end

  def self.zero_fill(num)
    "0" * (5 - num.to_s.length) + num.to_s
  end

  def find_parent_topic_item
    case kind
    when 'discussion_closed'   then discussion_created_topic_item
    when 'discussion_moved'    then discussion_created_topic_item
    when 'discussion_edited'   then discussion_created_topic_item
    when 'discussion_reopened' then discussion_created_topic_item
    when 'outcome_created'     then itemable.parent_topic_item
    when 'new_comment'
      p = itemable.parent
      candidate = p.is_a?(TopicItem) ? p : p&.created_topic_item
      candidate&.topic_id == topic_id ? candidate : topic.topicable&.created_topic_item
    when 'poll_closed_by_user' then itemable.created_topic_item
    when 'poll_created'
      if itemable.topic.topicable == itemable
        itemable.created_topic_item == self ? nil : itemable.created_topic_item
      else
        itemable.topic.topicable.created_topic_item
      end
    when 'poll_edited'         then itemable.created_topic_item
    when 'poll_reopened'       then itemable.created_topic_item
    when 'stance_created'      then itemable.parent_topic_item
    when 'stance_updated'      then itemable.parent_topic_item
    else
      nil
    end
  end

  def self_and_parents
    [self, parent&.self_and_parents].flatten.compact
  end

  def max_depth_adjusted_parent
    original_parent = find_parent_topic_item
    return nil unless original_parent
    if topic.max_depth == original_parent.depth
      original_parent.parent
    else
      original_parent
    end
  end

  def discussion_created_topic_item
    if itemable.respond_to?(:created_topic_item)
      itemable.created_topic_item
    elsif topic.topicable.respond_to?(:created_topic_item)
      topic.topicable.created_topic_item
    end
  end

  private

  def set_kind
    self.kind ||= self.class.name.demodulize.underscore
  end

  def set_itemable_version_id
    return if itemable_version_id || !itemable.respond_to?(:versions)

    self.itemable_version_id = itemable.versions.last&.id
  end

  def set_topic
    self.topic ||= itemable&.topic
  end

  def set_user_from_itemable
    self.user_id ||= itemable&.author_id
  end

  # When an topic_item's itemable is assigned but saved by a different association path
  # (e.g., in RecordCloner), the FK may be nil even though the target is persisted.
  def sync_itemable_foreign_key
    assoc = association(:itemable)
    if itemable_id.nil? && assoc.loaded? && assoc.target&.persisted?
      self.itemable_id = assoc.target.id
    end
  end
end
