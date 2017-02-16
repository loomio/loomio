#TODO: there are some discussion dependencies that will need to be resolved here
module Events::PollEvent
  include Events::NotifyUser
  include Events::EmailUser

  def trigger!(args = {})
    super
    poll.communities.each { |community| community.notify!(self) }
  end

  def poll
    @poll ||= eventable.poll
  end

  private

  def notification_recipients
    return User.none unless poll.group
    if announcement
      announcement_notification_recipients
    else
      specified_notification_recipients
    end
  end

  def announcement_notification_recipients
    poll.group.members
  end

  def specified_notification_recipients
    Queries::UsersToMentionQuery.for(poll)
  end

  def email_recipients
    return User.none unless poll.group
    if announcement
      announcement_email_recipients
    else
      specified_email_recipients
    end
  end

  def announcement_email_recipients
    Queries::UsersByVolumeQuery.normal_or_loud(poll.discussion)
  end

  def specified_email_recipients
    notification_recipients.where(email_when_mentioned: true)
  end

  def notification_translation_values
    super.merge(poll_type: I18n.t(:"poll_types.#{poll.poll_type}").downcase)
  end

  def mailer
    PollMailer
  end
end
