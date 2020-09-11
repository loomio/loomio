class Event < ApplicationRecord
  include Redis::Objects
  include CustomCounterCache::Model
  include HasTimeframe
  extend HasCustomFields
  counter :position_counter

  has_many :notifications, dependent: :destroy
  belongs_to :eventable, polymorphic: true
  belongs_to :discussion, required: false
  belongs_to :user, required: false
  belongs_to :parent, class_name: "Event", required: false
  has_many :children, (-> { where("discussion_id is not null") }), class_name: "Event", foreign_key: :parent_id
  set_custom_fields :pinned_title

  before_create :set_parent_and_depth
  before_create :set_sequences
  after_rollback :reset_sequences

  after_create  :update_sequence_info!
  after_destroy :update_sequence_info!

  define_counter_cache(:child_count) { |e| e.children.count  }
  define_counter_cache(:descendant_count) { |e|
    if e.kind == "new_discussion"
      Event.where(discussion_id: e.eventable_id).count
    else
      Event.where(discussion_id: e.discussion_id).
            where("id != ?", e.id).
            where('position_key like ?', e.position_key+"%").count
    end
  }
  update_counter_cache :parent, :child_count
  update_counter_cache :parent, :descendant_count
  update_counter_cache :discussion, :items_count

  validates :kind, presence: true
  validates :eventable, presence: true

  scope :unreadable, -> { where.not(kind: 'discussion_closed') }

  scope :invitations_in_period, ->(since, till) {
    where(kind: :announcement_created, eventable_type: 'Group').within(since.beginning_of_hour, till.beginning_of_hour)
  }

  delegate :group, to: :eventable, allow_nil: true
  delegate :poll, to: :eventable, allow_nil: true
  delegate :groups, to: :eventable, allow_nil: true
  delegate :update_sequence_info!, to: :discussion, allow_nil: true

  def self.publish!(eventable, **args)
    build(eventable, **args).tap(&:save!).tap(&:trigger!)
  end

  def self.bulk_publish!(eventables, **args)
    Array(eventables).map { |eventable| build(eventable, **args) }
                     .tap { |events| import(events) }
                     .tap { |events| events.map(&:trigger!) }
  end

  def self.build(eventable, **args)
    new({
      kind:       name.demodulize.underscore,
      eventable:  eventable
    }.merge(args))
  end

  def set_sequences
    set_sequence_id
    set_position_and_position_key
  end

  def reset_sequences
    reset_position_counter
    reset_sequence_id_counter
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

  def message_channel
    eventable.group.message_channel
  end
  # this is called after create, and calls methods defined by the event concerns
  # included per event type
  def trigger!
    EventBus.broadcast("#{kind}_event", self)
  end

  def active_model_serializer
    "Events::#{eventable.class.to_s.split('::').last}Serializer".constantize
  rescue NameError
    Events::BaseSerializer
  end

  def set_parent_and_depth
    return unless discussion_id
    self.parent = max_depth_adjusted_parent
    self.depth = parent ? parent.depth + 1 : 0
  end

  def set_parent_and_depth!
    set_parent_and_depth
    update_columns(parent_id: parent_id, depth: depth)
  end

  def set_sequence_id
    return unless discussion_id
    return if sequence_id
    self.sequence_id = next_sequence_id
  end

  def self.zero_fill(num)
    "0" * (5 - num.to_s.length) + num.to_s
  end

  def set_position_and_position_key!
    return unless discussion_id
    set_position_and_position_key
    update_columns(position: position, position_key: position_key)
  end

  def set_position_and_position_key
    return unless discussion_id
    return unless position == 0
    self.position = next_position
    self.position_key = self_and_parents.reverse.map(&:position).map{|p| Event.zero_fill(p) }.join('-')
  end


  def calendar_invite
    nil # only for announcement_created events for outcomes
  end

  def find_parent_event
    case kind
    when 'discussion_closed'   then eventable.created_event
    when 'discussion_forked'   then eventable.created_event
    when 'discussion_moved'    then discussion.created_event
    when 'discussion_edited'   then (eventable || discussion)&.created_event
    when 'discussion_reopened' then eventable.created_event
    when 'outcome_created'     then eventable.parent_event
    when 'new_comment'         then eventable.parent_event
    when 'poll_closed_by_user' then eventable.created_event
    when 'poll_closing_soon'   then eventable.created_event
    when 'poll_created'        then eventable.parent_event
    when 'poll_edited'         then eventable.created_event
    when 'poll_expired'        then eventable.created_event
    when 'poll_option_added'   then eventable.created_event
    when 'poll_reopened'       then eventable.created_event
    when 'stance_created'      then eventable.parent_event
    else
      nil
    end
  end

  def self_and_parents
    [self, (parent && parent.discussion_id && parent.self_and_parents)].flatten.compact
  end

  def next_sequence_id
    reset_sequence_id_counter if discussion.sequence_id_counter.nil?
    discussion.sequence_id_counter.increment
  end

  def reset_sequence_id_counter
    val = (Event.where(discussion_id: discussion_id).order("sequence_id DESC").limit(1).pluck(:sequence_id).first || 0)
    discussion.sequence_id_counter.reset(val)
  end

  def next_position
    return 0 unless self.discussion_id and self.parent_id
    reset_position_counter if parent.position_counter.nil?
    parent.position_counter.increment
  end

  def reset_position_counter
    return unless parent_id
    # EventService.reset_child_positions(parent_id, parent.position_key)
    val = (Event.where(parent_id: parent_id).order("position DESC").limit(1).pluck(:position).last || 0)
    parent.position_counter.reset(val)
  end

  def max_depth_adjusted_parent
    original_parent = find_parent_event
    return nil unless original_parent
    if discussion && discussion.max_depth == original_parent.depth
      original_parent.parent
    else
      original_parent
    end
  end
end
