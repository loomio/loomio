class Events::PollClosingSoon < Event
  include Events::Notify::InApp
  include Events::Notify::Author
  include Events::Notify::ByEmail
  include Events::Notify::ThirdParty

  def self.publish!(poll)
    super poll,
          user: poll.author,
          created_at: Time.now
  end

  def notify_author?
    eventable.notify_on_closing_soon == 'author'
  end

  private
  def email_recipients
    Queries::UsersByVolumeQuery.email_notifications(poll)
                               .where('users.id': raw_recipients.pluck(:id))
  end

  def notification_recipients
    Queries::UsersByVolumeQuery.app_notifications(poll)
                               .where('users.id': raw_recipients.pluck(:id))
  end

  def raw_recipients
    # work around for anonymous
    case poll.notify_on_closing_soon
    # when 'author'
    #   User.where(id: poll.author_id)
    when 'undecided_voters'
      poll.unmasked_undecided_voters
    when 'voters'
      poll.unmasked_voters
    else
      User.none
    end
  end

  def notification_translation_values
    super.merge(poll_type: I18n.t(:"poll_types.#{eventable.poll_type}"))
  end
end
