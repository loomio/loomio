class Views::EventMailer::Details < Views::ApplicationMailer::Component
  def initialize(poll:, recipient:)
    @poll, @recipient = poll, recipient
  end

  def view_template
    div(class: 'email-event-details') do
      p { strong { plain format_date_for_humans(@poll.event_starts_at, @recipient.time_zone, @recipient.date_time_pref) } }
      p { plain format_date_for_humans(@poll.event_ends_at, @recipient.time_zone, @recipient.date_time_pref) }
      p { plain @poll.event_location }
      p { plain t('calendar.invitation_hint') } unless @poll.event_cancelled?
    end
  end
end
