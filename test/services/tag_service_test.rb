require 'test_helper'

class TagServiceTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @group = groups(:group)
  end

  test "update_group_and_org_tags creates tags for tag names used in topics" do
    @group.topics.update_all(tags: ['proposal', 'urgent'])

    TagService.update_group_and_org_tags(@group.id)

    names = @group.tags.pluck(:name)
    assert_includes names, 'proposal'
    assert_includes names, 'urgent'
  end

  test "update_group_and_org_tags sets taggings_count based on usage" do
    @group.topics.update_all(tags: ['budget'])

    TagService.update_group_and_org_tags(@group.id)

    tag = @group.tags.find_by!(name: 'budget')
    assert_equal @group.topics.count, tag.taggings_count
  end

  test "update_group_and_org_tags zeroes count for tags not present in current topics" do
    stale_tag = Tag.create!(group: @group, name: 'stale', taggings_count: 5)
    @group.topics.update_all(tags: ['active'])

    TagService.update_group_and_org_tags(@group.id)

    assert_equal 0, stale_tag.reload.taggings_count
  end

  test "update_group_and_org_tags is a no-op for unknown group" do
    assert_nothing_raised do
      TagService.update_group_and_org_tags(-1)
    end
  end

  test "update_group_and_org_tags propagates org_taggings_count to parent group" do
    subgroup = groups(:subgroup)
    subgroup.topics.update_all(tags: ['strategy'])

    TagService.update_group_and_org_tags(subgroup.id)

    parent_tag = @group.tags.find_by(name: 'strategy')
    assert parent_tag, "expected a tag named 'strategy' on the parent group"
    assert parent_tag.org_taggings_count > 0
  end

  test "update_group_and_org_tags updates taggings_count on an existing tag" do
    tag = Tag.create!(group: @group, name: 'budget', taggings_count: 99)
    @group.topics.update_all(tags: ['budget'])

    TagService.update_group_and_org_tags(@group.id)

    assert_equal @group.topics.count, tag.reload.taggings_count
  end

  test "update_group_and_org_tags does not destroy existing tags when a new tag is added" do
    Tag.create!(group: @group, name: 'existing', taggings_count: 3)
    @group.topics.update_all(tags: ['existing', 'new-tag'])

    TagService.update_group_and_org_tags(@group.id)

    assert @group.tags.exists?(name: 'existing'), "existing tag should not be destroyed"
    assert @group.tags.exists?(name: 'new-tag'), "new tag should be created"
  end

  test "update_group_and_org_tags does not destroy existing tags when one is removed from topics" do
    Tag.create!(group: @group, name: 'removed', taggings_count: 5)
    Tag.create!(group: @group, name: 'kept', taggings_count: 2)
    @group.topics.update_all(tags: ['kept'])

    TagService.update_group_and_org_tags(@group.id)

    assert @group.tags.exists?(name: 'removed'), "removed tag record should still exist"
    assert_equal 0, @group.tags.find_by!(name: 'removed').taggings_count
    assert @group.tags.exists?(name: 'kept'), "kept tag should still exist"
  end

  test "update_group_and_org_tags sets exact org_taggings_count across subgroups" do
    subgroup = groups(:subgroup)
    @group.topics.update_all(tags: ['theme'])
    subgroup.topics.update_all(tags: ['theme'])

    TagService.update_group_and_org_tags(@group.id)
    TagService.update_group_and_org_tags(subgroup.id)

    parent_tag = @group.tags.reload.find_by!(name: 'theme')
    expected = @group.topics.count + subgroup.topics.count
    assert_equal expected, parent_tag.org_taggings_count
  end

  test "update_group_and_org_tags updates org_taggings_count on an existing parent tag" do
    Tag.create!(group: @group, name: 'policy', org_taggings_count: 99)
    subgroup = groups(:subgroup)
    subgroup.topics.update_all(tags: ['policy'])

    TagService.update_group_and_org_tags(subgroup.id)

    parent_tag = @group.tags.find_by!(name: 'policy')
    assert_equal subgroup.topics.count, parent_tag.org_taggings_count
  end
end
