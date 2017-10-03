class Event < ActiveRecord::Base
  include HasTimeframe

  has_many :notifications, dependent: :destroy
  belongs_to :eventable, polymorphic: true
  belongs_to :discussion, required: false
  belongs_to :user, required: false

  has_many :events_groups, dependent: :destroy
  has_many :groups, through: :events_groups

  scope :sequenced, -> { where.not(sequence_id: nil).order(sequence_id: :asc) }
  scope :chronologically, -> { order(created_at: :asc) }

  after_create :create_events_groups!
  after_create :trigger!
  after_create :call_thread_item_created
  after_destroy :call_thread_item_destroyed

  update_counter_cache :discussion, :items_count
  update_counter_cache :discussion, :salient_items_count

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

  private
  def create_events_groups!
    self.events_groups.import(
      related_groups.map {|g| EventsGroup.new(group_id: g.id, event_id: self.id) }
    )
  end

  # which groups are privvy to this event?
  def related_groups
    [self.discussion, self.eventable].compact.map do |o|
      if o.respond_to?(:groups)
        o.groups
      elsif o.respond_to?(:group)
        o.group
      end
    end.flatten.uniq.compact
  end

  def call_thread_item_created
    discussion.thread_item_created! if discussion_id.present?
  end

  def call_thread_item_destroyed
    discussion.thread_item_destroyed!(self) if discussion_id.present?
  end
end
