require 'test_helper'

class TagServiceTest < ActiveSupport::TestCase
  setup do
    @group = groups(:group)
    @subgroup = groups(:subgroup)
  end

  test "update_group_and_org_tags creates parent tag records for tags used in the org" do
    @group.topics.update_all(tags: ['proposal'])
    @subgroup.topics.update_all(tags: ['urgent'])

    TagService.update_group_and_org_tags(@subgroup.id)

    assert @group.tags.exists?(name: 'proposal')
    assert @group.tags.exists?(name: 'urgent')
    assert_not @subgroup.tags.exists?(name: 'urgent')
    assert_equal [@group.id], @group.tags.find_by!(name: 'proposal').used_group_ids
    assert_equal [@subgroup.id], @group.tags.find_by!(name: 'urgent').used_group_ids
  end

  test "clean_tag_names normalizes dedupes and sorts alphabetically" do
    names = TagService.clean_tag_names(['  Zeta  ', 'alpha', 'zeta', ' Beta  value '])

    assert_equal ['alpha', 'Beta value', 'Zeta'], names
  end

  test "update_group_and_org_tags preserves existing metadata when tags are still in use" do
    tag = Tag.create!(group: @group, name: 'budget', color: '#abcdef')
    @subgroup.topics.update_all(tags: ['budget'])

    TagService.update_group_and_org_tags(@subgroup.id)

    assert_equal '#abcdef', tag.reload.color
  end

  test "update_group_and_org_tags collapses legacy subgroup metadata into the parent group" do
    Tag.create!(group: @subgroup, name: 'legacy', color: '#abcdef')
    @subgroup.topics.update_all(tags: ['legacy'])

    TagService.update_group_and_org_tags(@subgroup.id)

    assert_equal '#abcdef', @group.tags.find_by!(name: 'legacy').color
    assert_equal [@subgroup.id], @group.tags.find_by!(name: 'legacy').used_group_ids
    assert_not @subgroup.tags.exists?(name: 'legacy')
  end

  test "update_group_and_org_tags does not destroy metadata for unused tags" do
    Tag.create!(group: @group, name: 'planned', color: '#abcdef')
    @group.topics.update_all(tags: ['active'])

    TagService.update_group_and_org_tags(@group.id)

    assert @group.tags.exists?(name: 'planned')
    assert @group.tags.exists?(name: 'active')
    assert_equal [], @group.tags.find_by!(name: 'planned').used_group_ids
  end

  test "update_group_and_org_tags normalizes whitespace and dedupes names case-insensitively" do
    @group.topics.update_all(tags: ['  Community   Energy  ', 'community energy'])

    TagService.update_group_and_org_tags(@group.id)

    assert_equal ['Community Energy'], @group.tags.where("lower(name) = ?", 'community energy').pluck(:name)
  end

  test "groom_duplicate_tags normalizes singleton metadata names" do
    tag = Tag.create!(group: @group, name: 'planned')
    Tag.where(id: tag.id).update_all(name: 'planned ')

    TagService.groom_duplicate_tags_for_group(@group.id)

    assert_equal 'planned', tag.reload.name
  end

  test "normalize_all_tag_names normalizes topics and metadata" do
    tag = Tag.create!(group: @group, name: 'planned')
    topic = @group.topics.first
    topic.update_columns(tags: ['planned ', '  Beta   tag'])
    Tag.where(id: tag.id).update_all(name: 'planned ')

    result = TagService.normalize_all_tag_names

    assert_equal ['Beta tag', 'planned'], topic.reload.tags
    assert_equal 'planned', tag.reload.name
    assert_equal 1, result[:topic_updates_count]
    assert result.key?(:tag_updates_count)
  end

  test "update_group_and_org_tags is a no-op for unknown group" do
    assert_nothing_raised do
      TagService.update_group_and_org_tags(-1)
    end
  end
end
