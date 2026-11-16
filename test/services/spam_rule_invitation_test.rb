require 'test_helper'

class SpamRuleInvitationTest < ActiveSupport::TestCase
  test 'invitations skip blocked new addresses existing users and explicit IDs' do
    actor = users(:admin)
    existing = users(:user)
    rule = SpamRule.create!(kind: 'regex', pattern: Regexp.escape(existing.email))
    SpamRule.create!(kind: 'email_domain', pattern: 'blocked.example')
    assert_no_difference 'User.count' do
      users = UserInviter.where_or_create!(emails: [ 'new@blocked.example', existing.email ],
        user_ids: [ existing.id ], model: groups(:group), actor: actor)
      assert_empty users
    end
    assert_equal 1, rule.hits.where(action: 'invitation').sum(:count)
  end

  test 'blocked recipients do not consume the last managed-site invitation slot' do
    actor = users(:user)
    group = groups(:group)
    blocked = users(:admin)
    assert_not actor.is_paying?
    prior_ids = Array.new(9) { |i| User.create!(email: "previous-invite-#{i}@example.com").id }
    Notification.create!(actor: actor, subject: group, kind: 'membership_created', recipient_user_ids: prior_ids)
    SpamRule.create!(kind: 'regex', pattern: Regexp.escape(blocked.email))
    SpamRule.create!(kind: 'email_domain', pattern: 'blocked.example')

    AppConfig.stub(:app_features, AppConfig.app_features.merge(subscriptions: true)) do
      recipients = UserInviter.where_or_create!(emails: [ 'last-slot@example.com', 'new@blocked.example' ],
        user_ids: [ blocked.id ], model: group, actor: actor)
      assert_equal [ 'last-slot@example.com' ], recipients.map(&:email)
      assert_not User.exists?(email: 'new@blocked.example')
      Membership.create!(group: group, user: recipients.first, inviter: actor)

      assert_no_difference 'User.count' do
        assert_raises(ThrottleService::LimitReached) do
          UserInviter.where_or_create!(emails: [ 'over-limit@example.com' ], user_ids: [], model: group, actor: actor)
        end
      end
    end
  end
end
