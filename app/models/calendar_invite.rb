class CalendarInvite
  include PrettyUrlHelper
  include FormattedDateHelper

  def initialize(outcome = Outcome.new)
    @calendar = build_calendar(outcome)
  end

  def to_ical
    @calendar&.to_ical
  end

  private

  def build_calendar(outcome)
    return unless outcome.poll_option && outcome.dates_as_options
    Icalendar::Calendar.new.tap do |calendar|
      calendar.event do |event|
        if outcome.poll_option.name.match /^\d+-\d+-\d+$/
          event.duration = "+P0W1D0H0M"
          event.dtstart  = outcome.poll_option.name.to_date
        else
          event.duration = "+P0W0D0H#{outcome.poll.meeting_duration}M"
          event.dtstart  = Icalendar::Values::DateTime.new(date_time(outcome.poll_option.name), tzid: 'UTC')
        end
        event.organizer   = Icalendar::Values::CalAddress.new(outcome.author.email, cn: outcome.author.name)
        event.summary     = outcome.event_summary
        event.description = outcome.event_description
        event.location    = outcome.event_location
        event.attendee    = outcome.attendee_emails
        event.ip_class    = outcome.poll.anyone_can_participate ? "PUBLIC" : "PRIVATE"
        event.url         = poll_url(outcome.poll)
      end
    end
  end
end
