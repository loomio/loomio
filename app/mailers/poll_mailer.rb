class PollMailer < BaseMailer
  layout 'thread_mailer'
  helper 'email'

  def poll_create(poll)
    send_poll_mail poll: poll, recipients: Queries::UsersToEmailQuery.poll_create(poll)
  end

  def poll_update(poll)
    send_poll_mail poll: poll, recipients: Queries::UsersToEmailQuery.poll_update(poll)
  end

  def poll_closing_soon(poll)
    send_poll_mail poll: poll, recipients: Queries::UsersToEmailQuery.poll_closing_soon(poll)
  end

  def outcome_create(outcome)
    send_poll_mail poll: outcome.poll, recipients: Queries::UsersToEmailQuery.outcome_create(outcome)
  end

  def outcome_update(outcome)
    send_poll_mail poll: outcome.poll, recipients: Queries::UsersToEmailQuery.outcome_update(outcome)
  end

  private

  def send_poll_mail(poll:, recipients:, priority: 2)
    @poll = poll

    headers = {
      "Precendence":              :bulk,
      "X-Auto-Response-Suppress": :OOF,
      "Auto-Submitted":           :"auto-generated"
    }

    delay(priority: priority).send_bulk_mail(to: recipients) do |user|
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
