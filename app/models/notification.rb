class Notification < ActiveRecord::Base

  BETA_NOTIFICATIONS = %w[comment_liked
                          comment_replied_to
                          membership_request_approved
                          membership_requested
                          motion_closed
                          motion_closed_by_user
                          motion_closing_soon
                          motion_outcome_created
                          new_comment
                          new_discussion
                          new_motion
                          new_vote
                          user_added_to_group
                          user_mentioned]

  belongs_to :user
  belongs_to :event

  validates_presence_of :user, :event
  validates_uniqueness_of :user_id, :scope => :event_id
  after_create :publish_message

  delegate :kind, :to => :event, :prefix => :event
  delegate :eventable, :to => :event

  scope :unviewed, -> { where(viewed: false) }
  scope :beta_notifications, -> { joins(:event).where(events: { kind: BETA_NOTIFICATIONS }) }

  def publish_message
    MessageChannelService.publish(NotificationSerializer.new(self).as_json, to: self.user)
  end
end
