class Event < ActiveRecord::Base
  include CustomCounterCache::Model
  include HasTimeframe
  include Events::Position
  BLACKLISTED_KINDS = ["motion_closed", "motion_outcome_updated", "motion_outcome_created", "new_vote", "new_motion", "motion_closed_by_user", "motion_edited"].freeze

  has_many :notifications, dependent: :destroy
  belongs_to :eventable, polymorphic: true
  belongs_to :discussion, required: false
  belongs_to :user, required: false

  scope :sequenced, -> { where.not(sequence_id: nil).order(sequence_id: :asc) }
  scope :chronologically, -> { order(created_at: :asc) }
  scope :thread_events, -> { where.not(kind: BLACKLISTED_KINDS) }
  # we don't use this but I think it's cool so lets see if we use it anytime soon else delete
  # scope :excluding_sequence_ids, -> (ranges) { where RangeSet.to_ranges(ranges).map {|r| "(sequence_id NOT BETWEEN #{r.first} AND #{r.last})"}.join(' AND ') }

  after_create :trigger!
  after_create :call_thread_item_created
  after_destroy :call_thread_item_destroyed

  update_counter_cache :discussion, :items_count

  validates :kind, presence: true
  validates :eventable, presence: true

  delegate :group, to: :eventable, allow_nil: true

  acts_as_sequenced scope: :discussion_id, column: :sequence_id, skip: lambda {|e| e.discussion.nil? || e.discussion_id.nil? }

  def active_model_serializer
    "Events::#{eventable.class.to_s.split('::').last}Serializer".constantize
  rescue NameError
    Events::BaseSerializer
  end

  # this is called after create, and calls methods defined by the event concerns
  # included per event type
  def trigger!
  end

  def should_have_parent?
    %w[stance_created
    poll_option_added
    poll_expired
    poll_edited
    poll_closing_soon
    poll_closed_by_user
    outcome_created
    new_comment
    discussion_moved
    discussion_edited].include?(self.kind) ||
    (self.kind == 'poll_created' && self.discussion_id.present?)
  end

  def ensure_parent_present!
    return if self.parent_id || !should_have_parent?
    self.update(parent: eventable.parent_event)
  end

  private

  def call_thread_item_created
    discussion.thread_item_created! if discussion.present?
  end

  def call_thread_item_destroyed
    discussion.thread_item_destroyed! if discussion.present?
  end
end
