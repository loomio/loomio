class NotificationItem
  attr_accessor :item, :notification

  def initialize(notification)
    @notification = notification
    @item = case notification.event_kind
      when "new_discussion"
        NotificationItems::NewDiscussion.new(notification)
      when "new_motion"
        NotificationItems::NewMotion.new(notification)
      when "motion_closed"
        NotificationItems::MotionClosed.new(notification)
      when "motion_closed_by_user"
        NotificationItems::MotionClosedByUser.new(notification)
      when "new_vote"
        NotificationItems::NewVote.new(notification)
      when "new_comment"
        NotificationItems::NewComment.new(notification)
      when "comment_liked"
        NotificationItems::CommentLiked.new(notification)
      when "comment_replied_to"
        NotificationItems::CommentRepliedTo.new(notification)
      when "membership_requested"
        NotificationItems::MembershipRequested.new(notification)
      when "membership_request_approved"
        NotificationItems::MembershipRequestApproved.new(notification)
      when "user_added_to_group"
        NotificationItems::UserAddedToGroup.new(notification)
      when "user_mentioned"
        NotificationItems::UserMentioned.new(notification)
      when "motion_closing_soon"
        NotificationItems::MotionClosingSoon.new(notification)
      when "motion_outcome_created"
        NotificationItems::MotionOutcomeCreated.new(notification)
    end
  end

  def actor
    notification.eventable.try(:user) || notification.event.user
  rescue => e
    raise [e, notification, notification.event].inspect
  end

  def title
    notification.eventable.discussion_title
  rescue => e
    raise [e, notification, notification.event].inspect
  end

  def group_full_name
    notification.eventable.group_full_name
  end

  def action_text
    raise "action_text must be overridden by subclass"
  end

  def avatar
    actor
  end

  def linkable
    raise "link must be overridden by subclass"
  end
end
