require 'test_helper'

class TagDestroyServiceTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @group = groups(:group)
    @subgroup = groups(:subgroup)

    @parent_discussion = DiscussionService.create(params: { title: "Parent #{SecureRandom.hex(4)}", group_id: @group.id, tags: ['apple', 'banana'] }, actor: @admin)
    @subgroup_discussion = DiscussionService.create(params: { title: "Subgroup #{SecureRandom.hex(4)}", group_id: @subgroup.id, tags: ['apple', 'banana'] }, actor: @admin)
    @other_discussion = DiscussionService.create(params: { title: "Other #{SecureRandom.hex(4)}", group_id: @group.id, tags: ['banana'] }, actor: @admin)

    TagService.update_group_tags(@group.id)
    TagService.update_group_tags(@subgroup.id)
  end

  test "removes matching topic tags in the group and subgroups" do
    TagService.destroy_by_name(@group.id, 'apple')

    assert_equal ['banana'], @parent_discussion.topic.reload.tags
    assert_equal ['banana'], @subgroup_discussion.topic.reload.tags
    assert_equal ['banana'], @other_discussion.topic.reload.tags
    assert_not Tag.exists?(group_id: [@group.id, @subgroup.id], name: 'apple')
  end
end
