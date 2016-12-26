class PollMailer < ActionMailer::Base

  def poll_create(poll)
    send_poll_mail(poll)
  end

  def poll_update(poll)
    send_poll_mail(poll)
  end

  def poll_closing_soon(poll)
    send_poll_mail(poll)
  end

  def outcome_created(poll)
    send_poll_mail(poll)
  end

  def outcome_updated(poll)
    send_poll_mail(poll)
  end

  private

  def send_poll_mail(poll, priority: 2)
    @poll = poll

    headers = {
      "Precendence":              :bulk,
      "X-Auto-Response-Suppress": :OOF,
      "Auto-Submitted":           :"auto-generated"
    }

    delay(priority: priority).send_bulk_mail(to: Queries::UsersToEmailQuery.send(action_name, poll)) do |user|
      send_single_mail(
        locale:        locale_for(user),
        to:            user.email,
        utm_hash:      utm_hash,
        subject_key:   "poll_mailer.#{action_name}_subject",
        subject_params: {
          poll_title:  poll.title,
          poll_author: poll.author.name
        }
      )
    end
  end

end
