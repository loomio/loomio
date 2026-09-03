require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @group = groups(:group)
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

  test "members excludes deactivated users but all_members retains them" do
    @group.add_member!(@user)
    @user.update!(deactivated_at: Time.current)

    assert_not_includes @group.members, @user
    assert_includes @group.all_members, @user
  end

  test "members and admins match the fixture membership matrix exactly" do
    expected_member_ids = users(
      :admin,
      :user,
      :member,
      :member_quiet,
      :member_normal,
      :member_loud,
      :reader_quiet,
      :reader_normal,
      :reader_loud,
      :member_guest_loud
    ).map(&:id).sort

    assert_equal expected_member_ids, @group.members.pluck(:id).sort
    assert_equal [ users(:admin).id ], @group.admins.pluck(:id)
  end

  test "alien group membership matrix is separate from the primary group" do
    alien_group = groups(:alien_group)
    expected_alien_ids = users(:alien, :alien_quiet, :alien_loud).map(&:id).sort

    assert_equal expected_alien_ids, alien_group.members.pluck(:id).sort
    assert_equal [ users(:alien).id ], alien_group.admins.pluck(:id)
    assert_empty @group.members.where(id: expected_alien_ids)
  end

  test "delivery scopes match the fixture membership volume matrix exactly" do
    normal = users(:admin, :user, :member, :member_normal)
    loud = users(:member_loud, :reader_quiet)
    expectations = {
      email_enabled_members: normal + loud,
      email_loud_members: loud,
      push_enabled_members: normal + loud,
      push_loud_members: loud
    }

    expectations.each do |scope_name, expected|
      actual_ids = @group.public_send(scope_name).pluck(:id)
      assert_equal expected.map(&:id).sort, actual_ids.sort, scope_name
    end
  end

  test "updates the memberships_count" do
    group = Group.create!(name: "Count Group #{SecureRandom.hex(4)}", group_privacy: 'secret')
    assert_difference -> { group.reload.memberships_count }, 1 do
      group.add_member!(@user)
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
    group = Group.create!(name: "Count Disc #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.add_admin!(@user)
    discussion = DiscussionService.create(params: { group_id: group.id, title: "Active Discussion" }, actor: @user)

    discarded = DiscussionService.create(params: { group_id: group.id, title: "Discarded Discussion" }, actor: @user)
    discarded.update!(discarded_at: Time.current)

    group.reload
    assert_equal 1, group.discussions_count
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
    group = groups(:alien_group)
    assert_equal [group.id], group.id_and_subgroup_ids
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
    assert total_memberships > group.reload.org_members_count
    assert_equal 2, group.org_members_count
  end
end
