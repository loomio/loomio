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
end
