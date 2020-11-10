class PollMailer < BaseMailer
  helper PollEmailHelper
  include PollEmailHelper

  REPLY_DELIMITER = "--"

  %w(
     invitation_created
     invitation_resend
     outcome_announced
     outcome_created
     outcome_updated
     outcome_created_author
     outcome_review_due
     poll_announced
     poll_closing_soon
     poll_closing_soon_author
     poll_created
     poll_edited
     poll_expired
     poll_expired_author
     poll_option_added
     poll_option_added_author
     stance_created
     user_mentioned
     user_reminded
   ).each do |action|
    define_method action, ->(recipient_id, event_id) { send_poll_email(recipient_id, event_id, action) }
  end

  private

  def subject_prefix(poll)
    poll.group ? "[#{@poll.group.full_name}] " : ''
  end

  def send_poll_email(recipient_id, event_id, action_name)
    @recipient = User.find_by!(id: recipient_id)
    @event = Event.find_by!(id: event_id)
    @action_name = action_name
    @poll = @event.eventable.poll
    return if User::BOT_EMAILS.values.include?(@recipient.email)
    headers = {
      "Precedence":               :bulk,
      "X-Auto-Response-Suppress": :OOF,
      "Auto-Submitted":           :"auto-generated"
    }

    if @event.eventable.respond_to?(:calendar_invite) && @event.eventable.calendar_invite
      attachments['meeting.ics'] = {
        content_type:              'text/calendar',
        content_transfer_encoding: 'base64',
        content:                   Base64.encode64(@event.eventable.calendar_invite)
      }
    end

    send_single_mail(
      locale:        @recipient.locale,
      to:            @recipient.email,
      from: from_user_via_loomio(@event.user),
      reply_to: reply_to_address_with_group_name(model: @event.eventable, user: @recipient),
      subject_prefix: subject_prefix(@poll),
      subject_key: "poll_mailer.subject.#{@action_name}#{@poll.wip? ? "_wip" : ''}",
      subject_params: {
        group: @poll.group.full_name,
        title: @poll.title,
        poll_type: I18n.t("poll_types.#{@poll.poll_type}"),
        actor: @event.user.name },
      layout:        'base_mailer'
    )
  end
end
