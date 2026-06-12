require 'test_helper'

class UpdateTagWorkerTest < ActiveSupport::TestCase
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

  test "renames matching topic tags in the group and subgroups" do
    UpdateTagWorker.new.perform(@group.id, 'apple', 'pear', '#aaa')

    assert_equal ['pear', 'banana'], @parent_discussion.topic.reload.tags
    assert_equal ['pear', 'banana'], @subgroup_discussion.topic.reload.tags
    assert_equal ['banana'], @other_discussion.topic.reload.tags
  end
end
