class Events::NewDiscussion < Event
  include Events::LiveUpdate
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::Mentions
  include Events::Notify::ThirdParty

  attr_accessor :discussion_readers
  attr_accessor :notify_group

  # def self.publish!(discussion, discussion_readers = nil, notify_group = false)
  #   super(discussion,
  #         user: discussion.author,
  #         discussion_readers: discussion_readers || DiscussionReader.none,
  #         notify_group: notify_group)
  # end

  def discussion
    eventable
  end

  def email_recipients
    member_ids = []
    if eventable.group_id && @notify_group && actor.can?(:announce, eventable)
      member_ids = eventable.group.accepted_memberships.email_announcements.pluck(:user_id)
    end
    user_ids =  member_ids.concat(discussion_readers.email_announcements.pluck(:user_id)).uniq
    User.distinct.active.where(id: user_ids).where.not(id: eventable.newly_mentioned_users)
  end

  def notification_recipients
    member_ids = []
    if eventable.group_id && @notify_group && actor.can?(:announce, eventable)
      member_ids = eventable.group.accepted_memberships.app_announcements.pluck(:user_id)
    end
    user_ids = member_ids.concat(discussion_readers.app_announcements.pluck(:user_id)).uniq
    User.distinct.active.where(id: user_ids)
  end
end
