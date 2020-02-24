class Event < ApplicationRecord
  include CustomCounterCache::Model
  include HasTimeframe
  extend HasCustomFields
  BLACKLISTED_KINDS = ["motion_closed", "motion_outcome_updated", "motion_outcome_created", "new_vote", "new_motion", "motion_closed_by_user", "motion_edited"].freeze

  has_many :notifications, dependent: :destroy
  belongs_to :eventable, polymorphic: true
  belongs_to :discussion, required: false
  belongs_to :user, required: false
  belongs_to :parent, class_name: "Event", required: false
  has_many :children, (-> { where("discussion_id is not null") }), class_name: "Event", foreign_key: :parent_id
  set_custom_fields :pinned_title

  acts_as_sequenced scope: :discussion_id, column: :sequence_id, skip: lambda {|e| e.discussion.nil? || e.discussion_id.nil? }

  before_create :set_parent_and_depth

  after_create  :update_sequence_info!
  after_destroy :update_sequence_info!

  after_save :reorder
  after_destroy :reorder

  define_counter_cache(:child_count) { |e| e.children.count  }
  update_counter_cache :parent, :child_count
  update_counter_cache :discussion, :items_count

  validates :kind, presence: true
  validates :eventable, presence: true

  scope :sequenced, -> { where.not(sequence_id: nil).order(sequence_id: :asc) }
  scope :thread_events, -> { where.not(kind: BLACKLISTED_KINDS) }

  scope :invitations_in_period, ->(since, till) {
    where(kind: :announcement_created, eventable_type: 'Group').within(since.beginning_of_hour, till.beginning_of_hour)
  }

  delegate :group, to: :eventable, allow_nil: true
  delegate :poll, to: :eventable, allow_nil: true
  delegate :groups, to: :eventable, allow_nil: true
  delegate :update_sequence_info!, to: :discussion, allow_nil: true

  def self.publish!(eventable, **args)
    build(eventable, **args).tap(&:save!).tap(&:trigger!)
  # rescue ActiveRecord::RecordNotUnique
  #   retry
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

  def self.reorder_with_parent_id(parent_id)
    ActiveRecord::Base.connection.execute(
      "UPDATE events SET position = t.seq
        FROM (
          SELECT id AS id, row_number() OVER(ORDER BY sequence_id) AS seq
          FROM events
          WHERE parent_id = #{parent_id}
          AND   discussion_id IS NOT NULL
        ) AS t
      WHERE events.id = t.id and
            events.position is distinct from t.seq")
  end

  def actor
    user
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

  def set_parent_and_depth!
    set_parent_and_depth
    update_columns(parent_id: parent_id, depth: depth)
  end

  def reload_position
    self.position = self.class.select(:position).find(self.id).position
  end

  def reorder
    return unless parent_id
    self.class.reorder_with_parent_id(parent_id)
    reload_position if self.persisted?
  end

  def calendar_invite
    nil # only for announcement_created events for outcomes
  end

  def email_subject_key
    nil
  end

  def find_parent_event
    case kind
    when 'discussion_closed'   then eventable.created_event
    when 'discussion_forked'   then eventable.created_event
    when 'discussion_moved'    then eventable.created_event
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

  private

  def set_parent_and_depth
    self.parent = max_depth_adjusted_parent
    self.depth = parent ? (parent.depth + 1) : 0
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
