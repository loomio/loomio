require "test_helper"
require Rails.root.join("db/migrate/support/membership_reference_integrity_cleanup")

class MembershipReferenceIntegrityCleanupTest < ActiveSupport::TestCase
  test "deletes invalid memberships and refreshes affected counters" do
    group = groups(:group)
    user = users(:user)
    missing_group_id = Group.maximum(:id) + 1
    missing_user_id = User.maximum(:id) + 1
    now = Time.current
    attributes = {
      accepted_at: now,
      admin: true,
      created_at: now,
      delegate: true,
      group_id: group.id,
      updated_at: now,
      user_id: missing_user_id,
      volume_email: Membership.volume_emails.fetch("normal"),
      volume_push: Membership.volume_pushes.fetch("normal")
    }

    invalid_ids = ActiveRecord::Base.connection.disable_referential_integrity do
      Membership.insert_all!([
        attributes,
        attributes.merge(group_id: missing_group_id, user_id: user.id)
      ]).rows.flatten
    end
    group.update_columns(
      memberships_count: 99,
      pending_memberships_count: 99,
      admin_memberships_count: 99,
      delegates_count: 99,
      org_members_count: 99
    )
    user.update_columns(memberships_count: 99)

    MembershipReferenceIntegrityCleanup.run!(ActiveRecord::Base.connection)

    assert_not Membership.where(id: invalid_ids).exists?
    group.reload
    assert_equal group.memberships.count, group.memberships_count
    assert_equal group.memberships.pending.count, group.pending_memberships_count
    assert_equal group.admin_memberships.count, group.admin_memberships_count
    assert_equal group.memberships.delegates.count, group.delegates_count
    assert_equal Membership.active.where(group_id: group.id_and_subgroup_ids).distinct.count(:user_id), group.org_members_count
    assert_equal user.memberships.count, user.reload.memberships_count
  end
end
