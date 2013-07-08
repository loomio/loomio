class NotificationItem
  attr_accessor :item, :notification

  delegate :actor, :action_text, :title, :group_full_name, :link, :avatar, :to => :item

  def initialize(notification)
    @notification = notification
    @item = case notification.event_kind
      when "new_discussion"
        NotificationItems::NewDiscussion.new(notification)
      when "new_motion"
        NotificationItems::NewMotion.new(notification)
      when "motion_edited"
        NotificationItems::MotionEdited.new(notification)
      when "motion_closed"
        NotificationItems::MotionClosed.new(notification)
      when "new_vote"
        NotificationItems::NewVote.new(notification)
      when "new_comment"
        NotificationItems::NewComment.new(notification)
      when "comment_liked"
        NotificationItems::CommentLiked.new(notification)
      when "membership_requested"
        NotificationItems::MembershipRequested.new(notification)
      when "user_added_to_group"
        NotificationItems::UserAddedToGroup.new(notification)
      when "user_mentioned"
        NotificationItems::UserMentioned.new(notification)
      when "motion_closing_soon"
        NotificationItems::MotionClosingSoon.new(notification)
      when "motion_blocked"
        NotificationItems::MotionBlocked.new(notification)
    end
  end

  def actor
    @notification.eventable.user
  end

  def title
    @notification.eventable.discussion_title
  end

  def group_full_name
    @notification.eventable.group_full_name
  end

  def avatar
    actor
  end
end