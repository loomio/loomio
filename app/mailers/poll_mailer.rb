class PollMailer < BaseMailer
  helper :email
  helper :application
  REPLY_DELIMITER = "--"

  # emails sent to the group
  def poll_created(recipient, event)
    send_poll_email recipient, event
  end

  def poll_edited(recipient, event)
    send_poll_email recipient, event
  end

  def outcome_created(recipient, event)
    send_poll_email recipient, event
  end

  def poll_closing_soon(recipient, event)
    send_poll_email recipient, event
  end

  def poll_closing_soon_author(recipient, event)
    send_poll_email recipient, event
  end

  def poll_expired(recipient, event)
    send_poll_email recipient, event
  end

  def visitor_reminded(recipient, event)
    send_poll_email recipient, event
  end

  private

  def send_poll_email(recipient, event)
    headers = {
      "Precedence":               :bulk,
      "X-Auto-Response-Suppress": :OOF,
      "Auto-Submitted":           :"auto-generated"
    }

    @info = PollEmailInfo.new(
      recipient:   recipient,
      poll:        event.poll,
      actor:       event.user,
      action_name: action_name
    )

    send_single_mail(
      locale:        locale_for(recipient),
      to:            recipient.email,
      subject_key:   "poll_mailer.#{@info.poll_type}.subject.#{action_name}",
      subject_params: { title: @info.poll.title, actor: @info.actor.name }
    )
  end
end
