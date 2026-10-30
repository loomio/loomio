module EventPollHelper
  def create_event_poll(actor: users(:admin), topic: topics(:discussion_topic), **overrides)
    topic&.update!(allow_concurrent_polls: true)
    start = 3.days.from_now.change(usec: 0)
    PollService.create(actor: actor, params: {
      title: 'Community gathering', details: '<p>Private meeting details</p>', details_format: 'html',
      poll_type: 'event', poll_template_key: 'event', topic_id: topic&.id,
      event_starts_at: start, event_ends_at: start + 1.hour, event_location: 'Town hall', time_zone: 'Pacific/Auckland',
      closing_at: start, notify_on_open: false,
      poll_options_attributes: [
        {name: 'Going', icon: 'agree', priority: 0},
        {name: 'Maybe', icon: 'abstain', priority: 1},
        {name: 'Not attending', icon: 'disagree', priority: 2}
      ]
    }.merge(overrides)).tap { |poll| assert poll.persisted?, poll.errors.full_messages.join(', ') }
  end

  def calendar_invitation(poll, user = users(:member_normal))
    CalendarInvitation.create!(poll: poll, user: user, email: user.email,
      delivered_sequence: poll.calendar_sequence, delivered_at: Time.current)
  end

  def calendar_reply(invitation, status: 'ACCEPTED', sequence: invitation.poll.calendar_sequence,
                     stamp: Time.current.change(usec: 0), uid: invitation.poll.calendar_uid,
                     sender: invitation.email, attendee: invitation.email,
                     organizer: invitation.organizer_email, authentication: nil, method: 'REPLY')
    authentication ||= "mx.loomio.test; dmarc=pass header.from=#{sender.split('@').last}"
    calendar = Icalendar::Calendar.new
    calendar.ip_method = method
    calendar.event do |event|
      event.uid = uid
      event.sequence = sequence
      event.dtstamp = stamp
      event.organizer = "mailto:#{organizer}"
      event.attendee = Icalendar::Values::CalAddress.new("mailto:#{attendee}", partstat: status)
    end
    mail = Mail.new
    mail.from = sender
    mail.to = invitation.organizer_email
    mail.subject = "Accepted: #{invitation.poll.title}"
    mail['Authentication-Results'] = authentication
    mail.content_type = "text/calendar; method=#{method}; charset=UTF-8"
    mail.body = calendar.to_ical
    store_inbound_mail(mail)
  end
end
