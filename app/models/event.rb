class Event < ActiveRecord::Base
  KINDS = %w[new_discussion discussion_title_edited discussion_description_edited discussion_edited discussion_moved
             new_comment new_motion new_vote motion_close_date_edited motion_name_edited motion_description_edited
             motion_edited motion_closing_soon motion_closed motion_closed_by_user motion_outcome_created
             motion_outcome_updated membership_requested invitation_accepted user_added_to_group user_joined_group
             new_coordinator membership_request_approved comment_liked comment_replied_to user_mentioned invitation_accepted]

  BULK_MAIL_KINDS = %w(new_comment motion_closing_soon motion_closed motion_outcome_created
                       new_discussion new_motion new_vote)

  SINGLE_MAIL_KINDS = %w(comment_replied_to user_mentioned)

  has_many :notifications, dependent: :destroy
  belongs_to :eventable, polymorphic: true
  belongs_to :discussion
  belongs_to :user

  scope :sequenced, -> { where('sequence_id is not null').order('sequence_id asc') }
  scope :chronologically, -> { order('created_at asc') }

  after_create :call_thread_item_created
  after_destroy :call_thread_item_destroyed

  validates_inclusion_of :kind, :in => KINDS
  validates_presence_of :eventable

  acts_as_sequenced scope: :discussion_id, column: :sequence_id, skip: lambda {|e| e.discussion.nil? || e.discussion_id.nil? }

  def notify!(user)
    notifications.create!(user: user) if user
  end

  private

  def call_thread_item_created
    discussion.thread_item_created!(self) if discussion_id.present?
  end

  def call_thread_item_destroyed
    discussion.thread_item_destroyed!(self) if discussion_id.present?
  end
end
