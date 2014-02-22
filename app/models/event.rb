class Event < ActiveRecord::Base
  KINDS = %w[new_discussion discussion_title_edited discussion_description_edited new_comment
             new_motion new_vote motion_blocked motion_close_date_edited
             motion_closing_soon motion_closed motion_closed_by_user motion_outcome_created motion_outcome_updated
             membership_requested invitation_accepted user_added_to_group membership_request_approved
             comment_liked user_mentioned]

  has_many :notifications, dependent: :destroy
  belongs_to :eventable, polymorphic: true
  belongs_to :discussion, counter_cache: :items_count
  belongs_to :user

  validates_inclusion_of :kind, :in => KINDS
  validates_presence_of :eventable

  acts_as_sequenced scope: :discussion_id, column: :sequence_id, skip: lambda {|e| e.discussion.nil? }


  def notify!(user)
    notifications.create!(user: user)
  end

  def belongs_to?(this_user)
    self.user_id == this_user.id
  end
end
