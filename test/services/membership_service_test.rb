require 'test_helper'

class MembershipServiceTest < ActiveSupport::TestCase
  setup do
    @admin = users(:user)
    @user = users(:alien)
    @group = Group.create!(
      name: 'Test Group',
      discussion_privacy_options: 'private_only',
      is_visible_to_public: false,
      membership_granted_upon: 'request',
      handle: "testgroup-#{SecureRandom.hex(4)}"
    )
    @group.add_admin!(@admin)
  end

  test "revoke cascade deletes subgroup memberships" do
    subgroup = Group.create!(
      name: 'Subgroup',
      parent: @group,
      handle: "#{@group.handle}-subgroup"
    )

    membership = @group.add_member!(@user)
    subgroup.add_member!(@user)

    assert_includes @group.members, @user
    assert_includes subgroup.members, @user

    MembershipService.revoke(membership: membership, actor: @user)

    assert_not_includes subgroup.reload.members, @user
  end

  test "revoke cascade deletes discussion reader access" do
    membership = @group.add_member!(@user)
    discussion = DiscussionService.create(params: { title: "Test", group_id: @group.id }, actor: @admin)

    # User should have access before revoke
    assert_includes @group.members, @user

    MembershipService.revoke(membership: membership, actor: @user)

    # User should not have access after revoke
    assert_not_includes @group.reload.members, @user
  end

  test "redeem sets accepted_at on membership" do
    unverified_user = User.create!(
      name: 'Unverified',
      email: 'unverified@example.com',
      email_verified: false,
      username: 'unverified'
    )

    membership = Membership.create!(
      user: unverified_user,
      group: @group,
      inviter: @admin,
      accepted_at: nil
    )

    MembershipService.redeem(membership: membership, actor: @user)

    assert_not_nil membership.reload.accepted_at
  end

  test "redeem handles simple case with inviter" do
    new_membership = Membership.create!(
      user_id: @user.id,
      group_id: @group.id,
      inviter_id: @admin.id
    )

    MembershipService.redeem(membership: new_membership, actor: @user)

    assert_equal @user.id, new_membership.reload.user_id
    assert_not_nil new_membership.reload.accepted_at
    assert_equal @admin.id, new_membership.reload.inviter_id
    assert_nil new_membership.reload.revoked_at
  end

  test "redeem updates existing membership instead of creating duplicate" do
    existing_membership = Membership.create!(
      user_id: @user.id,
      group_id: @group.id,
      accepted_at: 1.day.ago,
      inviter_id: @admin.id
    )

    second_inviter = User.create!(
      name: 'Second Inviter',
      email: 'inviter2@example.com',
      email_verified: true,
      username: 'inviter2'
    )
    @group.add_admin!(second_inviter)

    unverified_user = User.create!(
      name: 'Unverified',
      email: 'unverified2@example.com',
      email_verified: false,
      username: 'unverified2'
    )

    new_membership = Membership.create!(
      user_id: unverified_user.id,
      group_id: @group.id,
      inviter_id: second_inviter.id
    )

    MembershipService.redeem(membership: new_membership, actor: @user)

    assert_equal @user.id, existing_membership.reload.user_id
    assert_not_nil existing_membership.reload.accepted_at
    assert_nil existing_membership.reload.revoked_at
  end

  test "redeem unrevokes revoked membership" do
    existing_membership = Membership.create!(
      user_id: @user.id,
      group_id: @group.id,
      accepted_at: DateTime.now,
      revoked_at: DateTime.now,
      inviter_id: @admin.id,
      revoker_id: @admin.id
    )

    second_inviter = User.create!(
      name: 'Second Inviter',
      email: 'inviter3@example.com',
      email_verified: true,
      username: 'inviter3'
    )
    @group.add_admin!(second_inviter)

    unverified_user = User.create!(
      name: 'Unverified',
      email: 'unverified3@example.com',
      email_verified: false,
      username: 'unverified3'
    )

    new_membership = Membership.create!(
      user_id: unverified_user.id,
      group_id: @group.id,
      inviter_id: second_inviter.id
    )

    MembershipService.redeem(membership: new_membership, actor: @user)

    assert_equal @user.id, existing_membership.reload.user_id
    assert_equal second_inviter.id, existing_membership.reload.inviter_id
    assert_not_nil existing_membership.reload.accepted_at
    assert_nil existing_membership.reload.revoked_at
  end

  test "redeem notifies inviter of acceptance" do
    unverified_user = User.create!(
      name: 'Unverified',
      email: 'unverified4@example.com',
      email_verified: false,
      username: 'unverified4'
    )

    membership = Membership.create!(
      user: unverified_user,
      group: @group,
      inviter: @admin,
      accepted_at: nil
    )

    MembershipService.redeem(membership: membership, actor: @user)

    assert_equal 'invitation_accepted', Event.last.kind
  end

  test "redeem clears guest topic reader access in invited groups" do
    membership = pending_membership_for(@user, @group)
    discussion = DiscussionService.create(params: { title: "Guest access", group_id: @group.id }, actor: @admin)
    discussion.add_guest!(@user, @admin)

    reader = TopicReader.find_by!(topic: discussion.topic, user: @user)
    reader.update!(revoked_at: 1.day.ago, revoker_id: @admin.id)

    MembershipService.redeem(membership: membership, actor: @user)

    reader.reload
    assert_equal false, reader.guest
    assert_nil reader.revoked_at
    assert_nil reader.revoker_id
  end

  test "redeem unrevokes active poll stances in invited groups" do
    membership = pending_membership_for(@user, @group)
    poll = create_poll(group: @group)
    stance = poll.stances.create!(participant: @user, inviter: @admin, revoked_at: 1.day.ago, revoker_id: @admin.id)

    MembershipService.redeem(membership: membership, actor: @user)

    stance.reload
    assert_nil stance.revoked_at
    assert_nil stance.revoker_id
  end

  test "redeem does not unrevoke closed poll stances" do
    membership = pending_membership_for(@user, @group)
    poll = create_poll(group: @group, closed_at: 1.day.ago)
    stance = poll.stances.create!(participant: @user, inviter: @admin, revoked_at: 1.day.ago, revoker_id: @admin.id)

    MembershipService.redeem(membership: membership, actor: @user)

    stance.reload
    assert_not_nil stance.revoked_at
    assert_equal @admin.id, stance.revoker_id
  end

  test "redeem accepts all pending invitations in parent organisation" do
    subgroup = create_subgroup
    unverified_user = create_unverified_user("orginvite")
    parent_membership = pending_membership_for(unverified_user, @group)
    subgroup_membership = pending_membership_for(unverified_user, subgroup)

    MembershipService.redeem(membership: parent_membership, actor: @user)

    accepted_parent = Membership.find_by!(group: @group, user: @user)
    accepted_subgroup = Membership.find_by!(group: subgroup, user: @user)

    assert_not_nil accepted_parent.accepted_at
    assert_not_nil accepted_subgroup.accepted_at
    assert_equal parent_membership.id, accepted_parent.id
    assert_equal subgroup_membership.id, accepted_subgroup.id
    assert_empty Membership.where(user: unverified_user, group: [@group, subgroup])
  end

  test "revoke revokes topic reader access in group and subgroups" do
    subgroup = create_subgroup
    subgroup.add_admin!(@admin)
    membership = @group.add_member!(@user)
    subgroup.add_member!(@user)

    group_discussion = DiscussionService.create(params: { title: "Group topic", group_id: @group.id }, actor: @admin)
    subgroup_discussion = DiscussionService.create(params: { title: "Subgroup topic", group_id: subgroup.id }, actor: @admin)
    group_discussion.add_guest!(@user, @admin)
    subgroup_discussion.add_guest!(@user, @admin)

    revoked_at = 2.hours.ago
    MembershipService.revoke(membership: membership, actor: @user, revoked_at: revoked_at)

    [group_discussion, subgroup_discussion].each do |discussion|
      reader = TopicReader.find_by!(topic: discussion.topic, user: @user)
      assert_equal false, reader.guest
      assert_equal revoked_at.to_i, reader.revoked_at.to_i
      assert_equal @user.id, reader.revoker_id
    end
  end

  private

  def pending_membership_for(user, group)
    Membership.create!(
      user: user,
      group: group,
      inviter: @admin,
      accepted_at: nil
    )
  end

  def create_unverified_user(prefix)
    User.create!(
      name: prefix.titleize,
      email: "#{prefix}#{SecureRandom.hex(4)}@example.com",
      email_verified: false,
      username: "#{prefix}#{SecureRandom.hex(4)}"
    )
  end

  def create_subgroup
    Group.create!(
      name: "Subgroup #{SecureRandom.hex(4)}",
      parent: @group,
      handle: "#{@group.handle}-#{SecureRandom.hex(4)}"
    )
  end

  def create_poll(group:, closed_at: nil)
    PollService.create(params: {
      title: "Membership poll #{SecureRandom.hex(4)}",
      poll_type: "proposal",
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 3.days.from_now,
      group_id: group.id,
      specified_voters_only: true
    }, actor: @admin).tap do |poll|
      poll.update!(closed_at: closed_at) if closed_at
    end
  end
end
