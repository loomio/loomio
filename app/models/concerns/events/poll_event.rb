module Events::PollEvent
  include Events::Notify::InApp
  include Events::Notify::Users

  def poll
    @poll ||= eventable.poll
  end

  def mailer
    PollMailer
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
    poll.members
  end

  def specified_notification_recipients
    Queries::UsersToMentionQuery.for(eventable)
  end

  def email_recipients
    return User.none if poll.example
    if announcement
      announcement_email_recipients
    else
      specified_email_recipients
    end.without(poll.unsubscribers)
  end

  def announcement_email_recipients
    Queries::UsersByVolumeQuery.normal_or_loud((poll.discussion || poll.group), poll.guest_group)
  end

  def specified_email_recipients
    notification_recipients.where(email_when_mentioned: true)
  end

  def notification_translation_values
    super.merge(poll_type: I18n.t(:"poll_types.#{poll.poll_type}").downcase)
  end
end
