class TopicItem < ApplicationRecord
  CHANGE_NOTE_KINDS = %w[discussion_edited poll_edited].freeze

  include ActionView::Helpers::SanitizeHelper
  include PrettyUrlHelper

  belongs_to :itemable, polymorphic: true
  belongs_to :topic
  belongs_to :user, required: false
  belongs_to :parent, class_name: "TopicItem", required: false
  has_many :children, class_name: "TopicItem", foreign_key: :parent_id
  has_many :notifications, as: :subject, dependent: :destroy
  before_validation :set_kind, :set_itemable_version_id, :set_topic, :set_user_from_itemable, on: :create
  before_create :lock_topic_for_tree_change
  before_create :set_parent_and_depth
  before_create :increment_parent_child_count
  before_create :set_sequences
  after_rollback :reset_sequences
  before_destroy :lock_topic_for_tree_change
  before_destroy :reparent_children, unless: :destroyed_with_topic?
  before_destroy :reset_sequences

  after_create  :update_sequence_info!
  after_create  :mark_actor_as_read!
  after_destroy :update_sequence_info!

  after_update :update_parent_child_counts, if: :saved_change_to_parent_id?

  before_save :sync_itemable_foreign_key

  # Sequence/range updates already serialize writes to a topic. Acquire that
  # lock before its item locks too, matching moves, deletion and repair.
  def lock_topic_for_tree_change
    return if @tree_change_batched

    Topic.where(id: topic_id).lock('FOR NO KEY UPDATE').pick(:id)
  end
  private :lock_topic_for_tree_change

  # Increment before insertion to lock the parent against concurrent deletion.
  # Both the child and its count roll back together, and after-commit publication
  # sees the complete tree without a lock/read/recount transaction of its own.
  def increment_parent_child_count
    return if @tree_change_batched

    RecordCounts.update!(TopicItem, :child_count, before: nil, after: parent_id, records: [parent].compact)
  end

  def update_parent_child_counts
    RecordCounts.update!(TopicItem, :child_count,
      before: parent_id_before_last_save, after: parent_id, records: [parent].compact)
  end
  private :increment_parent_child_count, :update_parent_child_counts

  # Create a bounded collection of new timeline items in one transaction. The
  # topic lock excludes tree moves/deletions, so per-item parent increments can
  # be combined. Flush before leaving the transaction; after-commit workers
  # must never see the children with stale parent counts.
  def self.create_batch!(topic:, items:)
    transaction(requires_new: true) do
      Topic.where(id: topic.id).lock('FOR NO KEY UPDATE').pick(:id)
      deltas = Hash.new { |hash, id| hash[id] = { child_count: 0 } }
      parents = []
      items.each do |item|
        item.topic = topic
        item.send(:save_in_tree_batch!)
        next unless item.parent_id

        deltas[item.parent_id][:child_count] += 1
        parents << item.parent
      end
      RecordCounts.adjust!(TopicItem, deltas, records: parents)
    end
    items
  end

  def save_in_tree_batch!
    @tree_change_batched = true
    save!
  ensure
    @tree_change_batched = false
  end
  private :save_in_tree_batch!

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

    TopicReader.find_or_create_for!(topic: topic, user: reader).viewed!(sequence_id)
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

  # Edit notes belong to this timeline occurrence. Other notification messages
  # and recipient metadata are private to their delivery workflow.
  def change_note
    return unless CHANGE_NOTE_KINDS.include?(kind)

    notifications.where(kind: kind, actor_id: user_id).order(:id).pick(:recipient_message)
  end

  # A direct notification owns external delivery for its selected users, so
  # topic subscriber publication excludes those snapshotted recipients.
  def notification_recipient_user_ids
    notifications.flat_map(&:recipient_user_ids)
                 .compact
                 .map(&:to_i)
                 .uniq
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
    return unless parent_id

    # Creating children locks this row. Hold it while promoting existing
    # children so an insert cannot slip between promotion and deletion.
    TopicItem.where(id: [id, parent_id]).order(:id).lock.pluck(:id)
    promoted_count = TopicItem.where(parent_id: id).update_all(parent_id: parent_id, depth: depth)
    RecordCounts.adjust!(TopicItem, { parent_id => { child_count: promoted_count - 1 } }, records: [parent])
  end

  # A topic destroys every item in an unspecified order. Reparenting from the
  # stale in-memory objects can point descendants at an item already deleted
  # earlier in that cascade. Individual item deletion still reparents children.
  def destroyed_with_topic?
    destroyed_by_association == Topic.reflect_on_association(:items)
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

  # At the nesting limit, a reply and its actual parent become timeline siblings.
  # Include that comment as context without changing the display hierarchy.
  def reply_parent
    return unless kind == 'new_comment' && itemable.parent_type == 'Comment'

    candidate = TopicItem.where(topic_id: topic_id, kind: 'new_comment',
                               itemable_type: 'Comment', itemable_id: itemable.parent_id).order(:id).first
    candidate unless candidate&.id == parent_id
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
