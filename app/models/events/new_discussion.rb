class Events::NewDiscussion < Event
  include Events::Notify::Users
  include Events::Notify::Mentions
  include Events::LiveUpdate
  include Events::Notify::ThirdParty

  def self.publish!(discussion)
    super(discussion, user: discussion.author, announcement: discussion.make_announcement)
  end

  private

  def email_recipients
    if announcement
      Queries::UsersByVolumeQuery.normal_or_loud(eventable)
    else
      Queries::UsersByVolumeQuery.loud(eventable)
    end.without(eventable.author).without(eventable.mentioned_group_members)
  end

  def mailer
    ThreadMailer
  end
end
