class PollMailer < BaseMailer
  helper :email
  REPLY_DELIMITER = "--"

  def new_poll(recipient, event)
    send_poll_email recipient, event
  end

  def poll_edited(recipient, event)
    send_poll_email recipient, event
  end

  def poll_expired(recipient, event)
    send_poll_email recipient, event
  end

  def poll_closed_by_user(recipient, event)
    send_poll_email recipient, event
  end

  def poll_closing_soon(recipient, event)
    send_poll_email recipient, event
  end

  def poll_closing_soon_author(recipient, event)
    send_poll_email recipient, event
  end

  def new_outcome(recipient, event)
    send_poll_email recipient, event
  end

  private

  def send_poll_email(recipient, event)
    headers = {
      "Precedence":               :bulk,
      "X-Auto-Response-Suppress": :OOF,
      "Auto-Submitted":           :"auto-generated"
    }

    @info = PollEmailInfo.new(recipient: recipient, event: event, utm_hash: utm_hash)
    send_single_mail(
      locale:        locale_for(recipient),
      to:            recipient.email,
      subject_key:   "poll_mailer.#{poll.poll_type}.subject.#{action_name}",
      subject_params: { title: poll.title, actor: actor.name })
    end
  end
end
