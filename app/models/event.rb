class Event < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  include Redis::Objects
  include CustomCounterCache::Model
  include HasTimeframe
  extend HasCustomFields
  counter :position_counter
  lock :reset_position_counter, expiration: 5

  has_many :notifications, dependent: :destroy
  belongs_to :eventable, polymorphic: true
  belongs_to :discussion, required: false
  belongs_to :user, required: false
  belongs_to :parent, class_name: "Event", required: false
  has_many :children, (-> { where("discussion_id is not null") }), class_name: "Event", foreign_key: :parent_id
  set_custom_fields :pinned_title, :recipient_user_ids, :recipient_message, :recipient_audience

  before_create :set_parent_and_depth
  before_create :set_sequences
  after_rollback :reset_sequences

  after_create  :update_sequence_info!
  after_destroy :update_sequence_info!

  define_counter_cache(:child_count) { |e| e.children.count  }
  define_counter_cache(:descendant_count) { |e|
    if e.kind == "new_discussion"
      Event.where(discussion_id: e.eventable_id).count
    elsif e.position_key && e.discussion_id
      Event.where(discussion_id: e.discussion_id).
            where("id != ?", e.id).
            where('position_key like ?', e.position_key+"%").count
    else
      0
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

  def self.sti_find(id)
    e = self.find(id)
    e.kind_class.find(id)
  end

  def kind_class
    ("Events::"+kind.classify).constantize
  end

  def self.publish!(eventable, **args)
    event = build(eventable, **args).tap(&:save!)
    PublishEventWorker.perform_async(event.id)
    event
  end

  def self.bulk_publish!(eventables, **args)
    raise 'i hope we dont use this'
    Array(eventables).map { |eventable| build(eventable, **args) }
                     .tap { |events| import(events) }
                     .tap { |events| events.map(&:trigger!) }
  end

  def self.build(eventable, **args)
    new({
      kind:       name.demodulize.underscore,
      eventable:  eventable,
      eventable_version_id: ((eventable.respond_to?(:versions) && eventable.versions.last&.id) || nil)
    }.merge(args))
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
    EventSerializer
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

  def set_sequences
    set_sequence_id
    set_position_and_position_key
  end

  def reset_sequences
    puts "resetting sequences"
    self.position_counter.delete
    parent.position_counter.delete if parent_id
    discussion.sequence_id_counter.delete if discussion_id
  end

  def set_sequence_id
    return unless discussion_id
    return if sequence_id
    self.sequence_id = next_sequence_id!
  end

  def set_position_and_position_key
    return unless discussion_id
    return unless position == 0
    self.position = next_position!
    puts "setting position: #{position}"
    self.position_key = self_and_parents.reverse.map(&:position).map{|p| Event.zero_fill(p) }.join('-')
  end

  def next_sequence_id!
    reset_sequence_id_counter if discussion.sequence_id_counter.nil?
    discussion.sequence_id_counter.increment
  end

  def next_position!
    return 0 unless self.discussion_id and self.parent_id
    parent.reset_position_counter if parent.position_counter.nil?
    parent.position_counter.increment
  end

  def reset_sequence_id_counter
    return unless self.discussion_id
    discussion.reset_sequence_id_counter_lock do
      return unless discussion.sequence_id_counter.nil?
      val = (Event.where(discussion_id: discussion_id).order("sequence_id DESC").limit(1).pluck(:sequence_id).first || 0)
      discussion.sequence_id_counter.reset(val)
    end
  end

  def reset_position_counter
    reset_position_counter_lock do
      return unless self.position_counter.nil?
      val = (Event.where(parent_id: id,
                         discussion_id: discussion_id).order("position DESC").limit(1).pluck(:position).last || 0)
      puts "resetting position: #{val}"
      self.position_counter.reset(val)
    end
  end

  def self.zero_fill(num)
    "0" * (5 - num.to_s.length) + num.to_s
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


  def max_depth_adjusted_parent
    original_parent = find_parent_event
    return nil unless original_parent
    if discussion && discussion.max_depth == original_parent.depth
      original_parent.parent
    else
      original_parent
    end
  end

  def recipient_message=(val)
    self.custom_fields[:recipient_message] = strip_tags(val)
  end

  def email_recipients
    Queries::UsersByVolumeQuery.email_notifications(eventable).where(id: all_recipient_user_ids)
  end

  def notification_recipients
    Queries::UsersByVolumeQuery.app_notifications(eventable).where(id: all_recipient_user_ids)
  end

  def all_recipients
    User.active.where(id: all_recipient_user_ids)
  end

  def all_recipient_user_ids
    (recipient_user_ids || []).uniq.compact #.without(actor_id)
  end
end
