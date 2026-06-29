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
end
