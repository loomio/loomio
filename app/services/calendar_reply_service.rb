class CalendarReplyService
  ICON_BY_PARTSTAT = EventCalendarService::PARTSTAT_BY_ICON.invert.freeze
  CALENDAR_BYTES_MAX = 100_000
  TRUSTED_CALENDAR_SENDERS = {'calendar-notification@google.com' => 'google.com'}.freeze

  def self.process(email)
    new(email).process
  end

  def initialize(email)
    @email = email
  end

  # A reply can change only this invitation holder's attendance. Match the
  # private route, authenticated sender, ATTENDEE, ORGANIZER, event UID, and
  # current revision before using the ordinary voting service and permissions.
  def process
    return :bounced if @email.inbound_email.raw_email_blob.byte_size > 1.megabyte

    token = @email.route_path.match(/\Acalendar\+([A-Za-z0-9]+)\z/)&.[](1)
    return :bounced unless token && authenticated?
    invitation = CalendarInvitation.find_by(token: token)
    return :bounced unless invitation && sender_authorized?(invitation) && invitation.email == EmailAddress.normalize(invitation.user.email)

    parts = calendar_parts(@email.mail)
    return :bounced unless parts.length == 1 && parts.first.body.decoded.bytesize <= CALENDAR_BYTES_MAX
    calendars = Icalendar::Calendar.parse(parts.first.body.decoded)
    return :bounced unless calendars.length == 1
    calendar = calendars.first
    return :bounced unless calendar.ip_method.to_s.upcase == 'REPLY' && calendar.events.length == 1
    event = calendar.events.first
    return :bounced unless event.attendee.length == 1 && event.recurrence_id.nil?
    attendee = event.attendee.first
    return :bounced unless EmailAddress.normalize(attendee.to_s) == "mailto:#{invitation.email}"
    return :bounced unless EmailAddress.normalize(event.organizer.to_s) == EmailAddress.normalize("mailto:#{invitation.organizer_email}")
    icon = ICON_BY_PARTSTAT[Array(attendee.ical_params['partstat']).first.to_s.upcase]
    return :bounced unless icon && event.dtstamp
    stamp = event.dtstamp.to_time.utc
    return :bounced if stamp > 5.minutes.from_now

    result = :bounced
    invitation.poll.with_topic_lock do
      invitation.reload
      poll = invitation.poll.reload
      next unless poll.event? && !poll.event_cancelled? && invitation.user.can?(:vote_in, poll)
      next unless event.uid.to_s == poll.calendar_uid && event.sequence.to_i == poll.calendar_sequence
      next unless invitation.delivered_sequence == poll.calendar_sequence
      # Replays and older messages cannot replace a newer response, including
      # a vote cast in Loomio after this calendar reply was composed.
      next if invitation.response_sequence == poll.calendar_sequence && invitation.response_dtstamp && stamp <= invitation.response_dtstamp
      stance = poll.stances.latest.find_by!(participant_id: invitation.user_id)
      next if stance.cast_at && stamp < stance.updated_at.change(usec: 0)
      option = poll.poll_options.find_by!(icon: icon)
      response = StanceService.update(stance: stance, actor: invitation.user,
        params: {none_of_the_above: false, stance_choices_attributes: [{poll_option_id: option.id, score: 1}]})
      next unless response.valid?

      invitation.update!(response_sequence: poll.calendar_sequence, response_dtstamp: stamp)
      ActiveRecord.after_all_transactions_commit do
        if invitation.available?
          MessageChannelService.publish_models([poll.reload], user_id: invitation.user_id)
        end
      end
      result = :delivered
    end
    result
  rescue Icalendar::Parser::ParseError, ArgumentError, TypeError, CanCan::AccessDenied, ActiveRecord::RecordNotFound
    :bounced
  end

  private

  def sender_authorized?(invitation)
    sender = EmailAddress.normalize(@email.sender_email)
    return true if invitation.email == sender

    # Google Calendar sends attendance replies on behalf of its users. Trust
    # only its specific notification mailbox with a verified Google signature;
    # the private route, attendee, UID, revision, and permissions still apply.
    domain = TRUSTED_CALENDAR_SENDERS[sender]
    return false unless domain

    @email.header('authentication-results').to_s.split(';').any? do |result|
      result.match?(/\bdkim=pass\b/i) &&
        result.match?(/\bheader\.(?:d|i)=(?:[^\s;@]*@)?#{Regexp.escape(domain)}(?:\s|\z)/i)
    end
  end

  def calendar_parts(part, depth = 0)
    return [] if depth > 5
    return [part] if part.mime_type == 'text/calendar'
    return [] unless part.mime_type.to_s.start_with?('multipart/')
    return [] if part.parts.length > 10

    part.parts.flat_map { |child| calendar_parts(child, depth + 1) }
  end

  def authenticated?
    return false if @email.sender_authentication_failed?

    # Haraka strips sender-provided Authentication-Results and adds its own.
    # A positive aligned result is required; an absent result is not a pass.
    domain = Regexp.escape(@email.sender_hostname)
    @email.header('authentication-results').to_s.split(';').any? do |result|
      (result.match?(/\bdmarc=pass\b/i) && result.match?(/\bheader\.from=#{domain}(?:\s|\z)/i)) ||
        (result.match?(/\bdkim=pass\b/i) && result.match?(/\bheader\.(?:d|i)=(?:[^\s;@]*@)?(?:[a-z0-9-]+\.)*#{domain}(?:\s|\z)/i))
    end
  end
end
