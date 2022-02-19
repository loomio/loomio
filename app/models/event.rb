class Event < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  include CustomCounterCache::Model
  include HasTimeframe
  extend HasCustomFields

  has_many :notifications, dependent: :destroy
  belongs_to :eventable, polymorphic: true
  belongs_to :discussion, required: false
  belongs_to :user, required: false
  belongs_to :parent, class_name: "Event", required: false
  has_many :children, (-> { where("discussion_id is not null") }), class_name: "Event", foreign_key: :parent_id
  set_custom_fields :pinned_title, :recipient_user_ids, :recipient_message, :recipient_audience, :stance_ids

  before_create :set_parent_and_depth, if: :discussion_id
  before_create :set_sequences, if: :discussion_id
  after_rollback :reset_sequences, if: :discussion_id
  before_destroy :reset_sequences, if: :discussion_id

  after_create  :update_sequence_info!, if: :discussion_id
  after_destroy :update_sequence_info!, if: :discussion_id

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

  validates :kind, presence: true
  validates :eventable, presence: true

  scope :dangling, -> { joins('left join discussions d on events.discussion_id = d.id').where('d.id is null and discussion_id is not null') }
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
    event = build(eventable, **args)
    event.save!
    PublishEventWorker.perform_async(event.id)
    event
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
    self.parent = max_depth_adjusted_parent
    self.depth = parent ? parent.depth + 1 : 0
  end

  def set_parent_and_depth!
    set_parent_and_depth
    update_columns(parent_id: parent_id, depth: depth)
  end

  def set_sequences
    self.sequence_id = next_sequence_id!
    self.position = next_position!
    # self.position_key = self_and_parents.reverse.map(&:position).map{|p| Event.zero_fill(p) }.join('-')
    self.position_key = [parent&.position_key, Event.zero_fill(position)].compact.join('-')
  end

  def set_sequence_id!
    update_attribute(:sequence_id, next_sequence_id!)
  end

  def reset_sequences
    # drop_seq!(position_seq)
    drop_seq!(sequence_id_seq)
    EventService.reset_child_positions(parent.id, parent.position_key) if parent_id && parent
  end

  def sequence_id_seq
    "discussion_#{self.discussion_id}_sequence_id_seq"
  end

  def position_seq
    "event_#{self.parent_id}_position_seq"
  end

  def seq_present?(name)
    ActiveRecord::Base.connection.execute("SELECT 0 FROM pg_class where relname = '#{name}'" ).first.present?
  end

  def create_seq!(name, start, owner)
    ActiveRecord::Base.connection.execute("CREATE SEQUENCE IF NOT EXISTS #{name} START #{start} OWNED BY #{owner}")
  end

  def next_seq!(name)
    ActiveRecord::Base.connection.execute("SELECT NEXTVAL('#{name}')")[0]["nextval"]
  end

  def drop_seq!(name)
    ActiveRecord::Base.connection.execute("DROP SEQUENCE IF EXISTS #{name}")
  end

  def next_sequence_id!
    unless seq_present?(sequence_id_seq)
      val = 1 + (Event.where(discussion_id: discussion_id).
                       where("sequence_id is not null").
                       order(sequence_id: :desc).
                       limit(1).pluck(:sequence_id).last || 0)
      create_seq!(sequence_id_seq, val, "events.sequence_id")
    end
    next_seq!(sequence_id_seq)
  end

  def next_position!
    return 0 unless (discussion_id and parent_id)
    unless seq_present?(position_seq)
      val = 1 + (Event.where(parent_id: parent_id,
                             discussion_id: discussion_id).
                       order(position: :desc).
                       limit(1).pluck(:position).last || 0)
      create_seq!(position_seq, val, "events.position")
    end
    next_seq!(position_seq)
  end

  def self.zero_fill(num)
    "0" * (5 - num.to_s.length) + num.to_s
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
    when 'stance_updated'      then eventable.parent_event
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

  def email_recipients
    Queries::UsersByVolumeQuery.email_notifications(eventable).where(id: all_recipient_user_ids)
  end

  def notification_recipients
    Queries::UsersByVolumeQuery.app_notifications(eventable).where(id: all_recipient_user_ids).where.not(id: user.id || 0)
  end

  def all_recipients
    User.active.where(id: all_recipient_user_ids)
  end

  def all_recipient_user_ids
    (recipient_user_ids || []).uniq.compact #.without(actor_id)
  end
end
