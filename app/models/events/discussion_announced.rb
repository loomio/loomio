class Events::DiscussionAnnounced < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  attr_accessor :discussion_readers

  def self.publish!(model, actor, discussion_readers)
    super(model,
          user: actor,
          discussion_readers: discussion_readers)
  end

  private

  def email_recipients
    User.distinct.active.where(id: discussion_readers.email_announcements.pluck(:user_id) )
  end

  def notification_recipients
    User.distinct.active.where(id: discussion_readers.pluck(:user_id))
  end
end
