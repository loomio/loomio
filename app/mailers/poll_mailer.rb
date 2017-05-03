class PollMailer < BaseMailer
  helper :email
  helper :application
  REPLY_DELIMITER = "--"

  %w(poll_created poll_edited outcome_created
     poll_closing_soon poll_closing_soon_author
     poll_expired visitor_reminded visitor_created).each do |action|
    define_method action, ->(recipient, event) { send_poll_email(recipient, event, action) }
  end

  private

  def send_poll_email(recipient, event, action_name)
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
