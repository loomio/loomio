require 'test_helper'

class GroupServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
  end

  test "creates a new group" do
    group = Group.new(
      name: 'New Group',
      handle: "newgroup-#{SecureRandom.hex(4)}"
    )

    assert_difference 'Group.count', 1 do
      GroupService.create(group: group, actor: @user)
    end

    assert_equal @user, group.reload.creator
  end

  test "invites a user by email" do
    group = Group.create!(
      name: 'Invite Group',
      handle: "invitegroup-#{SecureRandom.hex(4)}"
    )
    group.add_admin!(@user)

    subscription = Subscription.create(max_members: nil)
    group.update!(subscription: subscription)

    initial_count = group.memberships.count

    GroupService.invite(
      group: group,
      actor: group.creator,
      params: { recipient_emails: ['test@example.com'] }
    )

    assert_equal initial_count + 1, group.memberships.count
  end

  test "does not mark membership as accepted if user doesnt belong to group already" do
    new_user = User.create!(
      name: 'Jim',
      email: 'jim@example.com',
      email_verified: true,
      username: 'jim'
    )

    group = Group.create!(
      name: 'Parent Group',
      handle: "parent-#{SecureRandom.hex(4)}"
    )
    group.add_admin!(@user)

    subscription = Subscription.create(max_members: nil)
    group.update!(subscription: subscription)

    GroupService.invite(
      group: group,
      actor: group.creator,
      params: { recipient_emails: [new_user.email] }
    )

    membership = Membership.find_by(user_id: new_user.id, group_id: group.id)
    assert_nil membership.accepted_at
  end

  test "marks membership as accepted if user already belongs to parent group" do
    parent = Group.create!(
      name: 'Parent Group',
      handle: "parent2-#{SecureRandom.hex(4)}",
      creator: @user
    )
    parent.add_admin!(@user)

    subgroup = Group.create!(
      name: 'Subgroup',
      parent: parent,
      handle: "#{parent.handle}-subgroup",
      creator: @user
    )
    subgroup.add_admin!(@user)

    another_user = users(:another_user)
    parent.add_member!(another_user, inviter: parent.creator)

    GroupService.invite(
      group: subgroup,
      actor: @user,
      params: { recipient_emails: [another_user.email] }
    )

    membership = Membership.find_by(user_id: another_user.id, group_id: subgroup.id)
    assert_not_nil membership.accepted_at
  end

  test "restricts group to subscription max_members" do
    group = Group.create!(
      name: 'Limited Group',
      handle: "limited-#{SecureRandom.hex(4)}"
    )
    group.add_admin!(@user)

    subscription = Subscription.create(max_members: 1)
    group.update!(subscription: subscription)

    initial_count = group.memberships.count

    assert_raises Subscription::MaxMembersExceeded do
      GroupService.invite(
        group: group,
        actor: group.creator,
        params: { recipient_emails: ['test@example.com'] }
      )
    end

    assert_equal initial_count, group.memberships.count
  end

  test "moves a group to a parent as an admin" do
    admin_user = User.create!(
      name: 'Admin',
      email: "admin-#{SecureRandom.hex(4)}@example.com",
      email_verified: true,
      username: "adminuser#{SecureRandom.hex(4)}",
      is_admin: true
    )

    group = Group.create!(
      name: 'Movable Group',
      handle: "movable-#{SecureRandom.hex(4)}",
      subscription_id: 100
    )

    parent = Group.create!(
      name: 'Parent Group',
      handle: "newparent-#{SecureRandom.hex(4)}"
    )

    GroupService.move(group: group, parent: parent, actor: admin_user)

    assert_equal parent, group.reload.parent
    assert_nil group.subscription_id
    assert_includes parent.reload.subgroups, group
  end

  test "does not allow non-admins to move groups" do
    group = Group.create!(
      name: 'Movable Group',
      handle: "movable2-#{SecureRandom.hex(4)}",
      subscription_id: 100
    )

    parent = Group.create!(
      name: 'Parent Group',
      handle: "newparent2-#{SecureRandom.hex(4)}"
    )

    assert_raises CanCan::AccessDenied do
      GroupService.move(group: group, parent: parent, actor: @user)
    end
  end
end
