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
    assert_equal 1, @group.reload.org_members_count

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

    assert_equal 1, @group.reload.org_members_count

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

  test "bulk creates invitation users with a bounded number of queries" do
    emails = 100.times.map { |index| "bulk-invite-#{index}@example.com" }
    queries = []
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |_name, _started, _finished, _id, payload|
      queries << payload[:sql] unless payload[:name].in?(['SCHEMA', 'TRANSACTION']) || payload[:cached]
    end

    users = UserInviter.where_or_create!(
      emails: emails,
      user_ids: [],
      model: @group,
      actor: @actor
    ).load

    assert_equal emails.sort, users.map(&:email).sort
    assert_equal 1, queries.count { |sql| sql.start_with?('INSERT INTO "users"') }
    assert_operator queries.length, :<=, 12
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end

  test "bulk invitation users have the usual generated attributes and preferences" do
    email = "new-invite-#{SecureRandom.hex(4)}@example.com"

    user = UserInviter.where_or_create!(
      emails: [email],
      user_ids: [],
      model: @group,
      actor: @actor
    ).find_by!(email: email)

    username_base = email.split('@').first.delete('-')[0, 18]
    assert_match(/\A#{Regexp.escape(username_base)}[a-z0-9]{12}\z/, user.username)
    assert_match(/\A[A-Za-z0-9]{8}\z/, user.key)
    assert_equal email.first(2).upcase, user.avatar_initials
    assert_equal @actor.time_zone, user.time_zone
    assert_equal @actor.date_time_pref, user.date_time_pref
    assert_equal @actor.locale, user.detected_locale
    assert_equal 7, user.email_catch_up_day
    assert user.unsubscribe_token.present?
    assert user.email_api_key.present?
    assert user.api_key.present?
    assert user.secret_token.present?
  end

  test "bulk invitations do not insert invalid or spam emails" do
    emails = [
      'not-an-email',
      'spam@diide.com'
    ]

    assert_no_difference('User.count') do
      users = UserInviter.where_or_create!(
        emails: emails,
        user_ids: [],
        model: @group,
        actor: @actor
      ).load

      assert_empty users
    end
  end

  test "invitation rate limiting is not applied when no limit is configured" do
    email = "private-host-#{SecureRandom.hex(4)}@example.com"
    trial_limit = ENV.delete('TRIAL_INVITATIONS_RATE_LIMIT')
    paid_limit = ENV.delete('PAID_INVITATIONS_RATE_LIMIT')

    ThrottleService.stub(:limit!, ->(**) { flunk('invitation limit was applied') }) do
      users = UserInviter.where_or_create!(
        emails: [email],
        user_ids: [],
        model: @group,
        actor: @actor
      ).load

      assert_equal [email], users.map(&:email)
    end
  ensure
    if trial_limit.nil?
      ENV.delete('TRIAL_INVITATIONS_RATE_LIMIT')
    else
      ENV['TRIAL_INVITATIONS_RATE_LIMIT'] = trial_limit
    end
    if paid_limit.nil?
      ENV.delete('PAID_INVITATIONS_RATE_LIMIT')
    else
      ENV['PAID_INVITATIONS_RATE_LIMIT'] = paid_limit
    end
  end
end
