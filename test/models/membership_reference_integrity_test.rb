require "test_helper"

class MembershipReferenceIntegrityTest < ActiveSupport::TestCase
  test "memberships require existing users and groups" do
    attributes = {
      accepted_at: Time.current,
      admin: false,
      created_at: Time.current,
      delegate: false,
      group_id: groups(:group).id,
      updated_at: Time.current,
      user_id: users(:user).id,
      volume_email: Membership.volume_emails.fetch("normal"),
      volume_push: Membership.volume_pushes.fetch("normal")
    }

    assert_raises(ActiveRecord::NotNullViolation) do
      Membership.transaction(requires_new: true) do
        Membership.insert_all!([ attributes.merge(group_id: nil) ])
      end
    end
    assert_raises(ActiveRecord::NotNullViolation) do
      Membership.transaction(requires_new: true) do
        Membership.insert_all!([ attributes.merge(user_id: nil) ])
      end
    end
    assert_raises(ActiveRecord::InvalidForeignKey) do
      Membership.transaction(requires_new: true) do
        Membership.insert_all!([ attributes.merge(group_id: Group.maximum(:id) + 1) ])
      end
    end
    assert_raises(ActiveRecord::InvalidForeignKey) do
      Membership.transaction(requires_new: true) do
        Membership.insert_all!([ attributes.merge(user_id: User.maximum(:id) + 1) ])
      end
    end
  end

  test "database cascades remove memberships with deleted users and groups" do
    group_membership = memberships(:member_membership)
    user_membership = memberships(:admin_membership)

    Group.where(id: group_membership.group_id).delete_all
    User.where(id: user_membership.user_id).delete_all

    assert_not Membership.exists?(group_membership.id)
    assert_not Membership.exists?(user_membership.id)
  end
end
