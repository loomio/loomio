class Event < ActiveRecord::Base
  include HasTimeframe

  has_many :notifications, dependent: :destroy
  belongs_to :eventable, polymorphic: true
  belongs_to :discussion, required: false
  belongs_to :user, required: false

  scope :sequenced, -> { where.not(sequence_id: nil).order(sequence_id: :asc) }
  scope :chronologically, -> { order(created_at: :asc) }

  after_create :trigger!
  after_create :call_thread_item_created
  after_destroy :call_thread_item_destroyed

  validates :kind, presence: true
  validates :eventable, presence: true

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

  # which communities should know about this event?
  # Polls override this to look at the communities associated with the poll.
  def communities
    Array(eventable&.group&.community)
  end

  def call_thread_item_created
    discussion.thread_item_created!(self) if discussion_id.present?
  end

  def call_thread_item_destroyed
    discussion.thread_item_destroyed!(self) if discussion_id.present?
  end
end
