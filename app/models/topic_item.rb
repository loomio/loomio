class TopicItem < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  include CustomCounterCache::Model
  include PrettyUrlHelper
  extend HasCustomFields

  belongs_to :itemable, polymorphic: true
  # topic_id marks this topic_item as a thread item: when set, the topic_item has a
  # sequence_id/position_key/parent_id and appears in the topic timeline. New
  # operational notifications no longer create null-topic topic_items, but the
  # association remains optional while historical rows are migrated. The
  # callbacks below must therefore continue to gate on topic_id until cutover.
  belongs_to :topic
  belongs_to :user, required: false
  belongs_to :parent, class_name: "TopicItem", required: false
  has_many :children, (-> { where("topic_id is not null") }), class_name: "TopicItem", foreign_key: :parent_id
  set_custom_fields :pinned_title, :recipient_user_ids, :recipient_chatbot_ids, :recipient_message, :recipient_audience, :stance_ids

  before_create :set_parent_and_depth, if: :topic_id
  before_create :set_sequences, if: :topic_id
  after_rollback :reset_sequences, if: :topic_id
  before_destroy :reparent_children
  before_destroy :reset_sequences, if: :topic_id

  after_create  :update_sequence_info!, if: :topic_id
  after_destroy :update_sequence_info!, if: :topic_id

  define_counter_cache(:child_count) { |e| e.children.where(topic_id: e.topic_id).count }
  update_counter_cache :parent, :child_count

  validates :kind, presence: true
  validates :itemable, presence: true

  before_save :sync_itemable_foreign_key

  scope :unreadable, -> { where.not(kind: 'discussion_closed') }

  delegate :group, to: :itemable, allow_nil: true
  delegate :poll, to: :itemable, allow_nil: true
  delegate :groups, to: :itemable, allow_nil: true
  delegate :update_sequence_info!, to: :topic, allow_nil: true

  def self.sti_find(id)
    e = self.find(id)
    e.kind_class.find(id)
  end

  def kind_class
    ("TopicItems::"+kind.classify).constantize
  end

  def self.publish!(itemable, **args)
    topic_item = build(itemable, **args)
    topic_item.save!
    PublishTopicItemWorker.perform_later(topic_item.id)
    topic_item
  end

  def self.publish_and_mark_read!(itemable, reader:, **args)
    topic_item = build(itemable, **args)
    topic_item.save!
    mark_created_topic_item_as_read_for(topic_item, reader)
    PublishTopicItemWorker.perform_later(topic_item.id)
    topic_item
  end

  def self.build(itemable, **args)
    new({
      kind:       name.demodulize.underscore,
      itemable:  itemable,
      itemable_version_id: ((itemable.respond_to?(:versions) && itemable.versions.last&.id) || nil)
    }.merge(args))
  end

  def self.mark_created_topic_item_as_read_for(topic_item, reader)
    return unless reader&.is_logged_in?
    return unless topic_item.topic_id && topic_item.sequence_id

    TopicReader.for(user: reader, topic: topic_item.topic).viewed!(topic_item.sequence_id)
    MessageChannelService.publish_models([topic_item], user_id: reader.id)
  end

  def user
    super || AnonymousUser.new
  end

  def real_user
    user
  end

  def actor
    user
  end

  def actor_id
    user_id
  end

  def notification_url
    model = case kind
            when 'stance_created'      then itemable.poll
            when 'invitation_accepted' then itemable.group
            else itemable
            end
    polymorphic_path(model)
  end


  # this is called after create, and calls methods defined by the topic_item concerns
  # included per topic_item type
  def trigger!
    EventBus.broadcast("#{kind}_event", self)
  end

  def active_model_serializer
    "TopicItems::#{itemable.class.to_s.split('::').last}Serializer".constantize
  rescue NameError
    TopicItemSerializer
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
    return 0 unless (topic_id and parent_id)
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
      candidate = p.is_a?(TopicItem) ? p : p&.topic_item
      candidate&.topic_id == topic_id ? candidate : topic&.topicable&.created_topic_item
    when 'poll_closed_by_user' then itemable.created_topic_item
    when 'poll_closing_soon'   then itemable.created_topic_item
    when 'poll_created'
      if itemable.topic.topicable == itemable
        itemable.created_topic_item == self ? nil : itemable.created_topic_item
      else
        itemable.topic.topicable.created_topic_item
      end
    when 'poll_edited'         then itemable.created_topic_item
    when 'poll_expired'        then itemable.created_topic_item
    when 'poll_option_added'   then itemable.created_topic_item
    when 'poll_reopened'       then itemable.created_topic_item
    when 'stance_created'      then itemable.parent_topic_item
    when 'stance_updated'      then itemable.parent_topic_item
    else
      nil
    end
  end

  def self_and_parents
    [self, (parent && parent.topic_id && parent.self_and_parents)].flatten.compact
  end

  def max_depth_adjusted_parent
    original_parent = find_parent_topic_item
    return nil unless original_parent
    if topic && topic.max_depth == original_parent.depth
      original_parent.parent
    else
      original_parent
    end
  end

  def notification_model
    topic || (itemable.respond_to?(:topic) && itemable.topic) || itemable
  end

  def email_recipients
    notification_model.volume_gte_normal_members.where(id: all_recipient_user_ids)
  end

  def notification_recipients
    notification_model.volume_gte_quiet_members.where(id: all_recipient_user_ids).where.not(id: user.id || 0)
  end

  def all_recipients
    User.active.where(id: all_recipient_user_ids)
  end

  def all_recipient_user_ids
    (recipient_user_ids || []).uniq.compact #.without(actor_id)
  end

  def discussion_created_topic_item
    if itemable.respond_to?(:created_topic_item)
      itemable.created_topic_item
    elsif topic&.topicable.respond_to?(:created_topic_item)
      topic.topicable.created_topic_item
    end
  end

  private

  # When an topic_item's itemable is assigned but saved by a different association path
  # (e.g., in RecordCloner), the FK may be nil even though the target is persisted.
  def sync_itemable_foreign_key
    assoc = association(:itemable)
    if itemable_id.nil? && assoc.loaded? && assoc.target&.persisted?
      self.itemable_id = assoc.target.id
    end
  end
end
