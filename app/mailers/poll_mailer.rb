class PollMailer < BaseMailer
  helper :email
  helper :application
  REPLY_DELIMITER = "--"

  %w(poll_created poll_edited outcome_created
     poll_closing_soon poll_closing_soon_author
     poll_expired  poll_expired_author
     visitor_reminded visitor_created
     stance_created).each do |action|
    define_method action, ->(recipient, event) { send_poll_email(recipient, event, action) }
  end

  private

  def send_poll_email(recipient, event, action_name)
    return if recipient == User.helper_bot
    headers = {
      "Precedence":               :bulk,
      "X-Auto-Response-Suppress": :OOF,
      "Auto-Submitted":           :"auto-generated"
    }

    actor = if event.eventable.is_a?(Stance) then event.eventable.participant else event.user end # sorry mom :(
    @info = PollEmailInfo.new(
      recipient:   recipient,
      poll:        event.poll,
      actor:       actor,
      eventable:   event.eventable,
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
