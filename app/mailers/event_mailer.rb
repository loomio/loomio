class EventMailer < ApplicationMailer
  after_deliver :record_calendar_delivery

  def invitation(invitation_id)
    @calendar_invitation = CalendarInvitation.find(invitation_id)
    poll = @calendar_invitation.poll
    recipient = @calendar_invitation.user
    return unless @calendar_invitation.available?
    return if spam?(recipient.email) || rejected_address?(recipient.email)

    @calendar_sequence = poll.calendar_sequence
    calendar = EventCalendarService.invitation(poll: poll, invitation: @calendar_invitation)
    method = poll.event_cancelled? ? 'CANCEL' : 'REQUEST'
    I18n.with_locale(first_supported_locale(recipient.locale)) do
      subject_key = poll.event_cancelled? ? 'invitation_cancelled' : 'invitation_updated'
      mail(to: recipient.email, subject: I18n.t("calendar.#{subject_key}", title: poll.title),
           reply_to: @calendar_invitation.organizer_email) do |format|
        format.html { render Views::EventMailer::Invitation.new(poll: poll, recipient: recipient) }
        format.ics { render plain: calendar, content_type: "text/calendar; method=#{method}; charset=UTF-8" }
      end
    end
    calendar_method!(method)
  end

  private

  def record_calendar_delivery
    return unless @calendar_invitation && @calendar_sequence

    @calendar_invitation.mark_delivered!(sequence: @calendar_sequence)
  end
end
