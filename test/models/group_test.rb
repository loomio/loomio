require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Group User #{SecureRandom.hex(4)}", email: "groupuser_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    @group = Group.create!(name: "Test Group #{SecureRandom.hex(4)}", group_privacy: 'secret')
  end

  # Memberships
  test "deletes memberships associated with it" do
    group = Group.create!(name: "Del Group #{SecureRandom.hex(4)}", group_privacy: 'secret')
    membership = group.add_member!(@user)
    group.destroy
    assert_raises(ActiveRecord::RecordNotFound) { membership.reload }
  end

  # Subgroups
  test "subgroup full_name contains parent name" do
    subgroup = Group.create!(name: "Sub #{SecureRandom.hex(4)}", parent: @group, group_privacy: 'secret')
    assert_equal "#{@group.name} - #{subgroup.name}", subgroup.full_name
  end

  test "subgroup full_name updates if parent name changes" do
    subgroup = Group.create!(name: "Sub #{SecureRandom.hex(4)}", parent: @group, group_privacy: 'secret')
    @group.name = "bluebird"
    @group.save!
    subgroup.reload
    assert_equal "bluebird - #{subgroup.name}", subgroup.full_name
  end

  # Hidden group membership operations
  test "can promote existing member to admin" do
    @group.add_member!(@user)
    @group.add_admin!(@user)
    assert_includes @group.admins, @user
  end

  test "can add a member" do
    @group.add_member!(@user)
    assert_includes @group.members, @user
  end

  test "updates the memberships_count" do
    assert_difference -> { @group.reload.memberships_count }, 1 do
      @group.add_member!(@user)
    end
  end

  test "sets the first admin to be the creator" do
    group = Group.new(name: "Creator Test #{SecureRandom.hex(4)}")
    group.add_admin!(@user)
    assert_equal @user, group.creator
  end

  # parent_members_can_see_discussions validation
  test "errors for hidden_from_everyone subgroup with parent_members_can_see_discussions" do
    parent = Group.create!(name: "Parent #{SecureRandom.hex(4)}", group_privacy: 'secret')
    assert_raises(ActiveRecord::RecordInvalid) do
      Group.create!(
        name: "Hidden Sub #{SecureRandom.hex(4)}",
        is_visible_to_public: false,
        is_visible_to_parent_members: false,
        parent: parent,
        parent_members_can_see_discussions: true
      )
    end
  end

  test "does not error for visible to parent subgroup with parent_members_can_see_discussions" do
    parent = Group.create!(name: "Parent #{SecureRandom.hex(4)}", group_privacy: 'secret')
    assert_nothing_raised do
      Group.create!(
        name: "Visible Sub #{SecureRandom.hex(4)}",
        is_visible_to_public: false,
        is_visible_to_parent_members: true,
        parent: parent,
        parent_members_can_see_discussions: true
      )
    end
  end

  # Discussion counts
  test "does not count a discarded discussion" do
    @group.add_admin!(@user)
    discussion = create_discussion(group: @group, author: @user)

    discarded = create_discussion(group: @group, author: @user, title: "Discarded Discussion")
    discarded.update!(discarded_at: Time.current)

    @group.reload
    assert_equal 0, @group.public_discussions_count
    assert_equal 1, @group.open_discussions_count
    assert_equal 0, @group.closed_discussions_count
    assert_equal 1, @group.discussions_count
  end

  # Archival
  test "archive sets archived_at on the group" do
    @group.add_member!(@user)
    @group.archive!
    assert @group.archived_at.present?
  end

  test "unarchive restores archived_at to nil" do
    @group.add_member!(@user)
    @group.archive!
    @group.unarchive!
    assert_nil @group.reload.archived_at
  end

  # id_and_subgroup_ids
  test "returns empty for new group" do
    assert Group.new.id_and_subgroup_ids.empty?
  end

  test "returns the id for groups with no subgroups" do
    assert_equal [@group.id], @group.id_and_subgroup_ids
  end

  test "returns the id and subgroup ids for group with subgroups" do
    subgroup = Group.create!(name: "Sub #{SecureRandom.hex(4)}", parent: @group, group_privacy: 'secret')
    @group.reload
    assert_includes @group.id_and_subgroup_ids, @group.id
    assert_includes @group.id_and_subgroup_ids, subgroup.id
  end

  # Org members count
  test "returns total number of unique members in the org" do
    user1 = User.create!(name: "Org1 #{SecureRandom.hex(4)}", email: "org1_#{SecureRandom.hex(4)}@test.com")
    user2 = User.create!(name: "Org2 #{SecureRandom.hex(4)}", email: "org2_#{SecureRandom.hex(4)}@test.com")
    group = Group.create!(name: "Org Group #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.add_admin!(user1)
    subgroup = Group.create!(name: "Org Sub #{SecureRandom.hex(4)}", parent: group, group_privacy: 'secret')
    subgroup.add_admin!(user2)
    # Also add user1 to subgroup so there's a duplicate user across groups
    subgroup.add_member!(user1)
    total_memberships = group.memberships.count + subgroup.memberships.count
    # total_memberships should be > org_members_count due to user1 being in both
    assert total_memberships > group.org_members_count
    assert_equal 2, group.org_members_count
  end
end
