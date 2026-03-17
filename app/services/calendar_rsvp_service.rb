class CalendarRsvpService
  include PrettyUrlHelper

  PARTSTAT_TO_ICON = {
    'ACCEPTED' => 'agree',
    'DECLINED' => 'disagree',
    'TENTATIVE' => 'abstain'
  }.freeze

  # Generate an ICS calendar invite for a proposal poll notification
  def self.build_ics(poll:, recipient:, reply_to:)
    new.build_ics(poll: poll, recipient: recipient, reply_to: reply_to)
  end

  def build_ics(poll:, recipient:, reply_to:)
    calendar = Icalendar::Calendar.new
    calendar.append_custom_property("METHOD", "REQUEST")

    calendar.event do |event|
      event.uid = "loomio-poll-#{poll.id}@#{ENV['CANONICAL_HOST']}"
      event.dtstart = Icalendar::Values::DateTime.new(poll.created_at.utc, tzid: 'UTC')
      event.dtend = Icalendar::Values::DateTime.new(poll.closing_at.utc, tzid: 'UTC')
      event.summary = poll.title
      event.description = poll_url(poll)
      event.organizer = Icalendar::Values::CalAddress.new(
        "mailto:#{reply_to}",
        cn: poll.author.name
      )
      event.attendee = Icalendar::Values::CalAddress.new(
        "mailto:#{recipient.email}",
        cn: recipient.name,
        "PARTSTAT" => "NEEDS-ACTION",
        "RSVP" => "TRUE"
      )
      event.ip_class = "PRIVATE"
      event.url = poll_url(poll)
    end

    calendar.to_ical
  end

  # Process an inbound calendar RSVP reply email
  # Returns true if handled, false if not a calendar RSVP
  def self.process(mail)
    calendar_part = mail.parts.find { |part| part.content_type&.include?('text/calendar') }
    return false unless calendar_part

    calendars = Icalendar::Calendar.parse(calendar_part.decoded)
    calendar = calendars.first
    return false unless calendar

    return false unless calendar.ip_method.to_s.upcase == "REPLY"

    event = calendar.events.first
    return false unless event

    uid = event.uid.to_s
    return false unless uid.match?(/\Aloomio-poll-\d+@/)

    poll_id = uid.match(/\Aloomio-poll-(\d+)@/)[1].to_i
    poll = Poll.find_by(id: poll_id)
    return false unless poll&.active? && poll.poll_type == 'proposal'

    partstat = extract_partstat(event)
    return false unless partstat && PARTSTAT_TO_ICON.key?(partstat)

    sender_email = mail.from&.first&.downcase
    actor = User.find_by(email: sender_email)
    return false unless actor

    icon = PARTSTAT_TO_ICON[partstat]
    poll_option = poll.poll_options.find { |o| o.icon == icon }
    return false unless poll_option

    cast_vote(poll: poll, poll_option: poll_option, actor: actor)
    true
  rescue => e
    Rails.logger.error("CalendarRsvpService error: #{e.class} #{e.message}")
    false
  end

  private

  def self.extract_partstat(event)
    attendee = Array(event.attendee).first
    return nil unless attendee
    Array(attendee.ical_params["partstat"]).first&.upcase
  end

  def self.cast_vote(poll:, poll_option:, actor:)
    stance = poll.stances.latest.find_by(participant: actor)
    return unless stance

    StanceService.update(
      stance: stance,
      actor: actor,
      params: {
        stance_choices_attributes: [{ poll_option_id: poll_option.id, score: 1 }]
      }
    )
  end
end
