require 'test_helper'

class CalendarSubscriptionTest < ActiveSupport::TestCase
  test 'leaving and rejoining a group does not reactivate an old calendar subscription' do
    membership = memberships(:member_normal_membership)
    subscription = CalendarSubscription.create!(membership: membership)
    old_token = subscription.token
    assert subscription.available?

    MembershipService.revoke(membership: membership, actor: users(:admin))
    assert_not CalendarSubscription.exists?(token: old_token)
    membership.group.add_member!(membership.user)
    assert membership.group.members_include?(membership.user)
    assert_not CalendarSubscription.exists?(token: old_token)
    fresh = CalendarSubscription.create!(membership: membership.reload)
    assert_not_equal old_token, fresh.token
    assert fresh.available?
  end
end
