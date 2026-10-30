class EventCalendarService
  include PrettyUrlHelper

  PARTSTAT_BY_ICON = {'agree' => 'ACCEPTED', 'abstain' => 'TENTATIVE', 'disagree' => 'DECLINED'}.freeze

  def self.invitation(poll:, invitation:)
    new.invitation(poll: poll, invitation: invitation)
  end

  def invitation(poll:, invitation:)
    calendar = Icalendar::Calendar.new
    calendar.prodid = '-//Loomio//Event invitations//EN'
    calendar.ip_method = poll.event_cancelled? ? 'CANCEL' : 'REQUEST'
    calendar.add_event(event(poll))
    item = calendar.events.first
    item.organizer = Icalendar::Values::CalAddress.new("mailto:#{invitation.organizer_email}", cn: poll.author.name)
    stance = poll.stances.latest.find_by(participant_id: invitation.user_id)
    icon = stance&.cast_at && stance.stance_choices.first&.poll_option&.icon
    item.attendee = Icalendar::Values::CalAddress.new("mailto:#{invitation.email}",
      cn: invitation.user.name, rsvp: icon ? 'FALSE' : 'TRUE', partstat: PARTSTAT_BY_ICON.fetch(icon, 'NEEDS-ACTION'))
    calendar.to_ical
  end

  def event(poll, include_details: true)
    Icalendar::Event.new.tap do |item|
      item.uid = poll.calendar_uid
      item.sequence = poll.calendar_sequence
      item.dtstamp = poll.updated_at.utc
      item.summary = poll.title
      item.description = include_details ? "#{poll_url(poll)}\n\n#{poll.details_visible_text}" : poll_url(poll)
      item.location = poll.event_location.to_s
      item.url = poll_url(poll)
      item.ip_class = 'PRIVATE'
      item.status = poll.event_cancelled? ? 'CANCELLED' : 'CONFIRMED'
      if poll.event_all_day?
        item.dtstart = Icalendar::Values::Date.new(poll.event_starts_at.in_time_zone(poll.time_zone).to_date)
        item.dtend = Icalendar::Values::Date.new(poll.event_ends_at.in_time_zone(poll.time_zone).to_date)
      else
        item.dtstart = Icalendar::Values::DateTime.new(poll.event_starts_at.utc, tzid: 'UTC')
        item.dtend = Icalendar::Values::DateTime.new(poll.event_ends_at.utc, tzid: 'UTC')
      end
    end
  end
end
