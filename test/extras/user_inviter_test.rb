require 'test_helper'

class UserInviterTest < ActiveSupport::TestCase
  setup do
    @actor = users(:admin)
    # max_members: 3 so the math is easy to follow in tests
    @group = Group.new(
      name: "Inviter Test",
      handle: "inviter-test-#{SecureRandom.hex(4)}",
      group_privacy: 'secret',
      subscription: Subscription.create!(plan: 'trial', max_members: 3)
    )
    @group.save!
    Membership.create!(user: @actor, group: @group, accepted_at: Time.current, admin: true)
  end

  # Regression: users could spam by sending invitations up to the trial limit,
  # canceling them (setting revoked_at), then sending more. The old code used
  # org_members_count which excludes revoked rows, so the slot appeared free.
  test "trial subscription counts revoked memberships toward the member limit" do
    # Simulate 2 canceled invitations — memberships that were created then revoked
    2.times do
      user = User.create!(email: "#{SecureRandom.hex(4)}@example.com", time_zone: 'UTC')
      Membership.create!(user: user, group: @group, accepted_at: Time.current, revoked_at: Time.current)
    end

    # org_members_count (old path) doesn't count revoked rows — only the actor
    assert_equal 1, @group.org_members_count

    # all_memberships.count (new trial path) includes revoked — actor + 2 revoked = 3
    assert_equal 3, @group.all_memberships.count

    # Inviting one more: existing(3) + new(1) = 4 > max_members(3) → should raise
    # Under the old code this would have been 1 + 1 = 2, which would pass.
    assert_raises(Subscription::MaxMembersExceeded) do
      UserInviter.authorize_add_members!(
        parent_group: @group,
        group_ids: [],
        emails: ["new-#{SecureRandom.hex(4)}@example.com"],
        user_ids: [],
        actor: @actor
      )
    end
  end

  test "trial subscription allows invite when total memberships are under the limit" do
    # 1 active member (actor), no revoked. existing(1) + new(1) = 2 ≤ 3 → OK
    assert_nothing_raised do
      UserInviter.authorize_add_members!(
        parent_group: @group,
        group_ids: [],
        emails: ["new-#{SecureRandom.hex(4)}@example.com"],
        user_ids: [],
        actor: @actor
      )
    end
  end

  test "non-trial subscription ignores revoked memberships when checking the limit" do
    @group.subscription.update!(plan: '2024-starter-annual', max_members: 3)

    # Add 2 revoked memberships — org_members_count stays at 1 (actor only)
    2.times do
      user = User.create!(email: "#{SecureRandom.hex(4)}@example.com", time_zone: 'UTC')
      Membership.create!(user: user, group: @group, accepted_at: Time.current, revoked_at: Time.current)
    end

    assert_equal 1, @group.org_members_count

    # Non-trial uses org_members_count: 1 + 1 = 2 ≤ 3 → allowed
    assert_nothing_raised do
      UserInviter.authorize_add_members!(
        parent_group: @group,
        group_ids: [],
        emails: ["new-#{SecureRandom.hex(4)}@example.com"],
        user_ids: [],
        actor: @actor
      )
    end
  end
end
