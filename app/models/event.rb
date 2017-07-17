class Event < ActiveRecord::Base
  include HasTimeframe

  KINDS = %w(new_discussion discussion_title_edited discussion_description_edited discussion_edited discussion_moved
             new_comment visitor_created membership_requested invitation_accepted user_added_to_group user_joined_group
             new_coordinator membership_request_approved comment_liked comment_replied_to user_mentioned invitation_accepted
             poll_created stance_created outcome_created poll_closed_by_user poll_expired poll_edited poll_closing_soon
             visitor_reminded outcome_published group_identity_created poll_option_added invitation_created).freeze

  has_many :notifications, dependent: :destroy
  belongs_to :eventable, polymorphic: true
  belongs_to :discussion
  belongs_to :user

  scope :sequenced, -> { where('sequence_id is not null').order('sequence_id asc') }
  scope :chronologically, -> { order('created_at asc') }

  after_create :call_thread_item_created
  after_destroy :call_thread_item_destroyed

  validates_inclusion_of :kind, in: KINDS
  validates_presence_of :eventable

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
