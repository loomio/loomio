require 'test_helper'
require_relative '../support/event_poll_helper'

class CalendarFeedsControllerTest < ActionController::TestCase
  include EventPollHelper

  setup do
    @poll = create_event_poll
    @subscription = CalendarSubscription.create!(membership: memberships(:member_normal_membership))
  end

  test 'a private subscription is readable without a Loomio session and contains no votes or participant addresses' do
    get :show, params: {token: @subscription.token}
    assert_response :success
    assert_equal 'text/calendar', response.media_type
    assert_includes response.headers['Cache-Control'], 'no-store'
    calendar = Icalendar::Calendar.parse(response.body).sole
    event = calendar.events.find { |item| item.uid.to_s == @poll.calendar_uid }
    assert event
    assert_empty event.attendee
    assert_nil event.organizer
    assert_equal 'TRANSPARENT', event.transp.to_s
    assert_not_includes response.body, 'Private meeting details'
    assert_not_includes response.body, users(:member_normal).email
    assert_not_includes response.body, users(:admin).email
  end

  test 'bad tokens revoked memberships inactive accounts and disabled groups cannot read the calendar' do
    get :show, params: {token: 'unknown'}
    assert_response :not_found
    @subscription.user.update!(deactivated_at: Time.current)
    get :show, params: {token: @subscription.token}
    assert_response :not_found
    @subscription.user.update!(deactivated_at: nil)
    @subscription.membership.update!(revoked_at: Time.current)
    get :show, params: {token: @subscription.token}
    assert_response :not_found
    assert_not CalendarSubscription.exists?(@subscription.id)
  end

  test 'foreign group and direct topic content is excluded even when the subscriber can access it' do
    direct = create_event_poll(topic: topics(:direct_topic), actor: users(:guest_admin_normal), title: 'Direct event')
    alien = create_event_poll(topic: topics(:alien_discussion_topic), actor: users(:alien), title: 'Foreign event')
    get :show, params: {token: @subscription.token}
    assert_response :success
    uids = Icalendar::Calendar.parse(response.body).sole.events.map { |item| item.uid.to_s }
    assert_includes uids, @poll.calendar_uid
    assert_not_includes uids, direct.calendar_uid
    assert_not_includes uids, alien.calendar_uid
  end

  test 'cancelled events retain a cancellation marker in subscriptions' do
    PollService.cancel_event(poll: @poll, actor: users(:admin))
    get :show, params: {token: @subscription.token}
    event = Icalendar::Calendar.parse(response.body).sole.events.find { |item| item.uid.to_s == @poll.calendar_uid }
    assert_equal 'CANCELLED', event.status.to_s
  end
end
