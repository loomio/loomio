class PollMailer < BaseMailer
  REPLY_DELIMITER = "--"

  %w(poll_created poll_announced poll_edited
     stance_created invitation_created invitation_resend
     poll_option_added poll_option_added_author
     outcome_created outcome_created_author outcome_announced
     poll_closing_soon poll_closing_soon_author
     poll_expired  poll_expired_author
     user_mentioned user_reminded).each do |action|
    define_method action, ->(recipient, event) { send_poll_email(recipient, event, action) }
  end

  private

  def send_poll_email(recipient, event, action_name)
    return if User::BOT_EMAILS.values.include?(recipient.email)
    headers = {
      "Precedence":               :bulk,
      "X-Auto-Response-Suppress": :OOF,
      "Auto-Submitted":           :"auto-generated"
    }

    @info = PollEmailInfo.new(
      recipient:   recipient,
      event:       event,
      action_name: action_name
    )

    if event.eventable.respond_to?(:calendar_invite) && event.eventable.calendar_invite
      attachments['meeting.ics'] = {
        content_type:              'text/calendar',
        content_transfer_encoding: 'base64',
        content:                   Base64.encode64(event.eventable.calendar_invite)
      }
    end

    send_single_mail(
      locale:        recipient.locale,
      to:            recipient.email,
      subject_key:   event.email_subject_key || "poll_mailer.#{@info.poll_type}.subject.#{@info.action_name}",
      subject_params: { title: @info.poll.title, actor: @info.actor.name },
      layout:        'base_mailer'
    )
  end
end
