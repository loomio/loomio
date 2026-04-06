require 'test_helper'

class Queries::ExploreGroupsTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)

    @group = Group.create!(name: "Explore Group #{SecureRandom.hex(4)}", handle: "explore_#{SecureRandom.hex(4)}")
    @group.subscription = Subscription.create(plan: 'trial', state: 'active')
    @group.save(validate: false)
    @group.update_attribute(:is_visible_to_public, true)
    @group.update_attribute(:listed_in_explore, true)
    @group.update_attribute(:memberships_count, 5)
    @group.update_attribute(:discussions_count, 3)

    @second_group = Group.create!(name: "Second Explore #{SecureRandom.hex(4)}", handle: "explore2_#{SecureRandom.hex(4)}")
    @second_group.subscription = Subscription.create(plan: 'trial', state: 'active')
    @second_group.save(validate: false)
    @second_group.update_attribute(:is_visible_to_public, true)
    @second_group.update_attribute(:memberships_count, 4)
    @second_group.update_attribute(:discussions_count, 1)

    @archived_group = Group.create!(name: "Archived Explore #{SecureRandom.hex(4)}", handle: "explore3_#{SecureRandom.hex(4)}", archived_at: 1.day.ago)
    @archived_group.subscription = Subscription.create(plan: 'trial', state: 'active')
    @archived_group.save(validate: false)
    @archived_group.update_attribute(:is_visible_to_public, true)
    @archived_group.update_attribute(:memberships_count, 5)
    @archived_group.update_attribute(:discussions_count, 3)
  end

  test "shows groups on the explore page" do
    results = Queries::ExploreGroups.new
    assert_includes results, @group
    refute_includes results, @archived_group
  end

  test "only shows groups that are listed_in_explore" do
    @group.update_attribute(:listed_in_explore, false)
    results = Queries::ExploreGroups.new
    refute_includes results, @group
  end

  test "only shows parent groups" do
    subgroup = Group.create!(name: "Sub Explore #{SecureRandom.hex(4)}", handle: "#{@group.handle}-sub#{SecureRandom.hex(4)}", parent: @group)
    subgroup.update_attribute(:is_visible_to_public, true)
    subgroup.update_attribute(:listed_in_explore, true)
    results = Queries::ExploreGroups.new
    refute_includes results, subgroup
  end

  test "returns groups with names that match the query" do
    @group.update_attribute(:name, 'Explore group unique')
    query = Queries::ExploreGroups.new
    assert_includes query.search_for('unique'), @group
  end

  test "returns groups with descriptions that match the query" do
    @group.update_attribute(:description, 'A group for exploring things')
    query = Queries::ExploreGroups.new
    assert_includes query.search_for('exploring'), @group
  end

  test "does not return groups that do not match the query" do
    @group.update_attribute(:name, 'Group')
    query = Queries::ExploreGroups.new
    refute_includes query.search_for('explore'), @group
  end

  test "returns all visible groups when query is not present" do
    query = Queries::ExploreGroups.new
    assert_includes query.search_for(nil), @group
  end
end
