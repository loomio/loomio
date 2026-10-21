require "test_helper"

class Ability::ReceivedEmailTest < ActiveSupport::TestCase
  test "group email is visible to its coordinators rather than topic guests or instance administrators" do
    email = ReceivedEmail.new(group: groups(:group))

    assert users(:admin).can?(:show, email)
    %i[user member_normal guest_normal guest_admin_normal alien non_guest_loud
       former_member_loud former_guest_loud inactive_guest_loud server_admin].each do |role|
      assert_not users(role).can?(:show, email), role.to_s
    end
    assert_not LoggedOutUser.new.can?(:show, email)
  end

  test "revoking a coordinator membership removes group email access" do
    coordinator = users(:member_normal)
    membership = memberships(:member_normal_membership)
    membership.update!(admin: true)
    email = ReceivedEmail.new(group: groups(:group))
    assert coordinator.can?(:show, email)

    membership.update!(revoked_at: Time.current)
    coordinator.reload

    assert_not coordinator.can?(:show, email)
  end
end
