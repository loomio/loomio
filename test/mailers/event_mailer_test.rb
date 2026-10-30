require 'test_helper'
require_relative '../support/event_poll_helper'

class EventMailerTest < ActionMailer::TestCase
  include EventPollHelper

  setup do
    @poll = create_event_poll
    @user = users(:member_normal)
  end

  test 'event notification is a native meeting request with a recipient-specific reply route' do
    message = NotificationMailer.topic_item(@user.id, @poll.created_topic_item.id).deliver_now
    part = message.all_parts.find { |item| item.mime_type == 'text/calendar' }
    assert part, message.encoded
    assert_match(/method=REQUEST/i, part.content_type)
    calendar = Icalendar::Calendar.parse(part.decoded).sole
    assert_equal 'REQUEST', calendar.ip_method.to_s
    event = calendar.events.sole
    invitation = CalendarInvitation.find_by!(poll: @poll, user: @user)
    assert_equal @poll.calendar_uid, event.uid.to_s
    assert_equal "mailto:#{invitation.organizer_email}", event.organizer.to_s
    assert_equal ["mailto:#{@user.email}"], event.attendee.map(&:to_s)
    assert_equal ['NEEDS-ACTION'], event.attendee.sole.ical_params['partstat']
    assert_equal ['TRUE'], event.attendee.sole.ical_params['rsvp']
    assert_not_includes part.decoded, users(:admin).email
    assert_equal 0, invitation.delivered_sequence
    assert invitation.delivered_at
    assert_includes message.html_part.decoded, 'Town hall'
    assert_includes message.html_part.decoded, 'Respond in your calendar'
  end

  test 'updates and cancellations reuse the event identity and advance its revision' do
    invitation = calendar_invitation(@poll, @user)
    PollService.update(poll: @poll, actor: users(:admin), params: {
      event_starts_at: @poll.event_starts_at + 1.hour, event_ends_at: @poll.event_ends_at + 1.hour
    })
    message = EventMailer.invitation(invitation.id).deliver_now
    part = message.all_parts.find { |item| item.mime_type == 'text/calendar' }
    event = Icalendar::Calendar.parse(part.decoded).sole.events.sole
    assert_equal @poll.calendar_uid, event.uid.to_s
    assert_equal 1, event.sequence.to_i
    assert_equal @poll.event_starts_at.to_i, event.dtstart.to_time.to_i
    assert_equal 1, invitation.reload.delivered_sequence

    PollService.cancel_event(poll: @poll, actor: users(:admin))
    message = EventMailer.invitation(invitation.id).deliver_now
    part = message.all_parts.find { |item| item.mime_type == 'text/calendar' }
    calendar = Icalendar::Calendar.parse(part.decoded).sole
    assert_match(/method=CANCEL/i, part.content_type)
    assert_equal 'CANCEL', calendar.ip_method.to_s
    assert_equal 'CANCELLED', calendar.events.sole.status.to_s
    assert_equal @poll.calendar_uid, calendar.events.sole.uid.to_s
    assert_equal 2, calendar.events.sole.sequence.to_i
  end

  test 'all-day dates retain their event timezone and exclusive end' do
    zone = 'Pacific/Auckland'
    start = 3.days.from_now.in_time_zone(zone).beginning_of_day
    poll = create_event_poll(time_zone: zone, event_all_day: true, event_starts_at: start, event_ends_at: start + 1.day)
    invitation = calendar_invitation(poll)
    event = Icalendar::Calendar.parse(EventCalendarService.invitation(poll: poll, invitation: invitation)).sole.events.sole
    assert_instance_of Icalendar::Values::Date, event.dtstart
    assert_equal start.to_date, event.dtstart.to_date
    assert_equal start.to_date + 1.day, event.dtend.to_date
  end

  test 'deleting an event or its discussion cancels delivered invitations' do
    standalone = create_event_poll(topic: nil, group_id: @poll.group_id)
    [@poll, standalone].each do |poll|
      invitation = calendar_invitation(poll, @user)
      result = TopicService.discard(topic: poll.topic, actor: users(:admin))
      assert result.discarded?
      assert poll.reload.discarded?
      assert_equal 1, poll.calendar_sequence
      assert_difference 'ActionMailer::Base.deliveries.count', 1 do
        CalendarUpdateWorker.perform_now(poll.id)
      end
      calendar = Icalendar::Calendar.parse(ActionMailer::Base.deliveries.last.all_parts.find { |part| part.mime_type == 'text/calendar' }.decoded).sole
      assert_equal 'CANCEL', calendar.ip_method.to_s
      assert_equal poll.calendar_uid, calendar.events.sole.uid.to_s
      assert_equal 1, invitation.reload.delivered_sequence
    end
  end

  test 'calendar update worker retries without resending an already delivered revision' do
    invitation = calendar_invitation(@poll, @user)
    PollService.update(poll: @poll, actor: users(:admin), params: {event_location: 'New meeting room'})
    assert_difference 'ActionMailer::Base.deliveries.count', 1 do
      CalendarUpdateWorker.perform_now(@poll.id)
    end
    assert_equal @poll.calendar_sequence, invitation.reload.delivered_sequence
    assert_no_difference 'ActionMailer::Base.deliveries.count' do
      CalendarUpdateWorker.perform_now(@poll.id)
    end
    invitation.mark_delivered!(sequence: 0)
    assert_equal @poll.calendar_sequence, invitation.reload.delivered_sequence
  end

  test 'revoked access and changed recipient addresses prevent calendar updates' do
    invitation = calendar_invitation(@poll, @user)
    @user.memberships.active.where(group: @poll.group).first.update!(revoked_at: Time.current)
    assert_no_difference 'ActionMailer::Base.deliveries.count' do
      EventMailer.invitation(invitation.id).deliver_now
    end
  end

  test 'time poll outcomes record the time without sending an untracked calendar invitation' do
    poll = PollService.create(actor: users(:admin), params: {
      title: 'Find a meeting time', poll_type: 'availability', topic_id: @poll.topic_id,
      poll_option_names: [@poll.event_starts_at.iso8601], closing_at: 1.day.from_now, notify_on_open: false
    })
    PollService.close(poll: poll, actor: users(:admin))
    outcome = OutcomeService.create(actor: users(:admin), outcome: Outcome.new(poll: poll,
      poll_option: poll.poll_options.first, statement: 'Chosen time', event_summary: 'Our gathering'))
    message = NotificationMailer.topic_item(@user.id, outcome.created_topic_item.id).deliver_now
    assert_not message.all_parts.any? { |part| part.mime_type == 'text/calendar' }
    assert_equal 0, poll.calendar_invitations.count
  end
end
