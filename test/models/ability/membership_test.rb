require "test_helper"
require_relative "../../support/access_volume_matrix"

class Ability::MembershipTest < ActiveSupport::TestCase
  test "membership details belong to its owner inviter and group coordinators" do
    membership = memberships(:member_normal_membership)
    inviter = users(:member_quiet)
    membership.update!(inviter: inviter)
    actors = AccessVolumeMatrix::ROLES.map { |role| users(role) } + [users(:server_admin), LoggedOutUser.new]
    allowed_ids = [membership.user_id, inviter.id, users(:admin).id]

    actors.each do |actor|
      assert_equal allowed_ids.include?(actor.id), actor.can?(:show, membership), actor.id.to_s
    end
  end

  test "only a group coordinator can resend an invitation and accepted memberships cannot be resent" do
    membership = memberships(:member_normal_membership)
    actors = AccessVolumeMatrix::ROLES.map { |role| users(role) } + [users(:server_admin), LoggedOutUser.new]
    # Authentication rejects inactive accounts; this policy reads active coordinator memberships.
    coordinator_ids = [users(:admin).id, users(:inactive_member_loud).id]
    [nil, Time.current].each do |accepted_at|
      membership.update!(accepted_at: accepted_at)
      actors.each do |actor|
        expected = accepted_at.nil? && coordinator_ids.include?(actor.id)
        assert_equal expected, actor.can?(:resend, membership), "#{actor.id}: accepted=#{accepted_at.present?}"
      end
    end
  end

  test "a parent coordinator can promote their own subgroup membership without promoting others" do
    parent_coordinator = users(:admin)
    own_membership = memberships(:admin_subgroup_membership)
    own_membership.update!(admin: false)
    other_membership = memberships(:subgroup_user_membership)
    other_membership.update!(admin: true)

    assert groups(:group).admins.exists?(parent_coordinator.id)
    assert_not groups(:subgroup).admins.exists?(parent_coordinator.id)
    assert parent_coordinator.can?(:make_admin, own_membership)
    assert_not parent_coordinator.can?(:make_admin, other_membership)
  end
end
