class PollMailer < BaseMailer
  REPLY_DELIMITER = "--"
  layout 'invite_people_mailer', only: 'stance_created_author'

  %w(poll_created poll_announced poll_edited
     stance_created stance_created_author
     invitation_created invitation_resend
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

    if invite = event.calendar_invite
      attachments['meeting.ics'] = {
        content_type:              'text/calendar',
        content_transfer_encoding: 'base64',
        content:                   Base64.encode64(invite)
      }
    end

    send_single_mail(
      locale:        recipient.locale,
      to:            recipient.email,
      subject_key:   "poll_mailer.#{@info.poll_type}.subject.#{email_subject_key}",
      subject_params: { title: @info.poll.title, actor: @info.actor.name },
      layout:        layouts[action_name].to_s
    )
  end

  def layouts
    HashWithIndifferentAccess.new { :base_mailer }.merge(stance_created_author: :invite_people_mailer)
  end

  def email_subject_key
    case @info.eventable
    when Invitation then @info.eventable.intent
    else                 @info.action_name
    end
  end
end
