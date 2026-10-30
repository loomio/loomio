require 'test_helper'
require_relative '../../../support/event_poll_helper'

class Api::V1::GroupCalendarsTest < ActionController::TestCase
  tests Api::V1::GroupsController
  include EventPollHelper

  setup do
    @poll = create_event_poll
    @group = @poll.group
    @range = {id: @group.id, start: Date.current.iso8601, end: 14.days.from_now.to_date.iso8601}
  end

  test 'members get the same authorized calendar entries as group admins' do
    %i[member_normal admin].each do |role|
      sign_in users(role)
      get :calendar, params: @range
      assert_response :success
      entries = JSON.parse(response.body).fetch('entries')
      assert_includes entries.map { |entry| entry['id'] }, @poll.calendar_uid
      assert_not_includes response.body, 'Private meeting details'
      assert_not_includes response.body, users(:member_normal).email
    end
  end

  test 'subscription links belong to the current membership and can be reset independently' do
    sign_in users(:member_normal)
    post :calendar_subscription, params: {id: @group.id}
    assert_response :success
    first = JSON.parse(response.body).fetch('url')
    own = CalendarSubscription.find_by!(membership: memberships(:member_normal_membership))
    assert_includes first, own.token
    post :calendar_subscription, params: {id: @group.id}
    assert_equal first, JSON.parse(response.body).fetch('url')

    other = CalendarSubscription.create!(membership: memberships(:admin_membership))
    post :reset_calendar_subscription, params: {id: @group.id}
    assert_response :success
    assert_not_equal first, JSON.parse(response.body).fetch('url')
    assert_not CalendarSubscription.exists?(token: own.token)
    assert CalendarSubscription.exists?(other.id)
  end

  test 'guests outsiders revoked members and inactive users cannot create group calendar subscriptions' do
    %i[guest_normal guest_admin_normal non_guest_loud alien_loud former_member_loud inactive_member_loud].each do |role|
      sign_in users(role)
      assert_no_difference 'CalendarSubscription.count' do
        post :calendar_subscription, params: {id: @group.id}
      end
      assert_includes [401, 403, 404], response.status, role.to_s
    end
  end

  test 'calendar date ranges are bounded and malformed dates are rejected' do
    sign_in users(:member_normal)
    assert_raises(ActionController::BadRequest) { get :calendar, params: @range.merge(end: 1.year.from_now.to_date.iso8601) }
    assert_raises(ActionController::BadRequest) { get :calendar, params: @range.merge(start: 'invalid') }
  end
end
