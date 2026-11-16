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
end
