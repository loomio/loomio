require 'test_helper'

class ServerMembershipServiceTest < ActiveSupport::TestCase
  setup do
    @group = groups(:group)
    @membership = memberships(:member_normal_membership)
  end

  test 'failed invitations roll back new accounts removals access and counts without publishing' do
    user = @membership.user
    reader = TopicReader.for(user: user, topic: topics(:discussion_topic))
    reader.update!(guest: true)
    before_counts = @group.reload.attributes.slice('memberships_count', 'admin_memberships_count', 'org_members_count')
    clear_enqueued_jobs

    assert_no_difference [ 'User.count', 'Membership.count', 'Notification.count' ] do
      ActionCable.server.stub(:broadcast, ->(*) { flunk 'Rolled-back access must not be broadcast' }) do
        NotificationService.stub(:create!, ->(**) { raise 'notification failed' }) do
          assert_raises RuntimeError do
            ServerMembershipService.sync(group: @group, emails: [ 'rollback-provisioning@example.org' ], remove_absent: true)
          end
        end
      end
    end
    assert_nil @membership.reload.revoked_at
    assert_nil reader.reload.revoked_at
    assert reader.guest?
    assert_equal before_counts, @group.reload.attributes.slice(*before_counts.keys)
    assert_no_enqueued_jobs
  end

  test 'role notification failures roll back all roles profiles and group counts' do
    before = @group.reload.admin_memberships_count
    NotificationService.stub(:create!, ->(**) { raise 'notification failed' }) do
      assert_raises RuntimeError do
        ServerMembershipService.update(membership: @membership, params: { admin: true, delegate: true })
      end
    end
    refute @membership.reload.admin?
    refute @membership.delegate?
    assert_equal before, @group.reload.admin_memberships_count
    assert_nil @membership.user.reload.experiences.dig('delegates', @group.id.to_s)
  end

  test 'count failures roll back server membership removals and access revocation' do
    reader = TopicReader.for(user: @membership.user, topic: topics(:discussion_topic))
    reader.update!(guest: true)
    Group.stub(:update_org_members_count_for_group_ids, ->(*) { raise 'count failed' }) do
      assert_raises RuntimeError do
        ServerMembershipService.revoke(membership: @membership)
      end
    end
    assert_nil @membership.reload.revoked_at
    assert_nil reader.reload.revoked_at
    assert reader.guest?
  end

  test 'member limit failures roll back provisioning and new accounts' do
    subscription = Subscription.for(@group)
    subscription.update!(plan: 'community', state: 'active', max_members: 0)
    assert_no_difference [ 'User.count', 'Membership.count', 'Notification.count' ] do
      assert_raises Subscription::MaxMembersExceeded do
        ServerMembershipService.sync(group: @group, emails: [ 'over-limit@example.org' ])
      end
    end
  end

  test 'expired subscriptions reject additions and role changes but permit access revocation' do
    subscription = Subscription.for(@group)
    subscription.update!(expires_at: 1.day.ago)
    assert_raises Subscription::NotActive do
      ServerMembershipService.sync(group: @group, emails: [ 'expired-provisioning@example.org' ])
    end
    assert_raises Subscription::NotActive do
      ServerMembershipService.update(membership: @membership, params: { admin: true })
    end
    refute User.exists?(email: 'expired-provisioning@example.org')
    ServerMembershipService.revoke(membership: @membership)
    assert_not_nil @membership.reload.revoked_at
  end
end
