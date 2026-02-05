require 'test_helper'

class Api::V1::TagsControllerTest < ActionController::TestCase
  setup do
    @user = users(:normal_user)
    @group = groups(:test_group)
    @subgroup = Group.create!(
      name: "Test Subgroup",
      parent: @group,
      handle: "testgroup-subgroup"
    )
    
    @discussion = create_discussion(group: @group, author: @user, tags: ['apple', 'banana'])
    @poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      group: @group,
      author: @user,
      tags: ['apple', 'banana']
    )
    PollService.create(poll: @poll, actor: @user)
    
    @group.add_admin!(@user) unless @group.members.include?(@user)
    @subgroup.add_admin!(@user) unless @subgroup.members.include?(@user)
    
    @sub_discussion = create_discussion(group: @subgroup, author: @user, tags: ['apple', 'banana'])
    @sub_poll = Poll.new(
      title: "Subgroup Poll",
      poll_type: "proposal",
      group: @subgroup,
      author: @user,
      tags: ['apple', 'banana']
    )
    PollService.create(poll: @sub_poll, actor: @user)
    
    TagService.update_group_tags(@subgroup.id)
    TagService.update_group_and_org_tags(@group.id)
    
    sign_in @user
  end

  test "create creates a new tag" do
    post :create, params: { tag: { name: 'newtag', color: '#ccc', group_id: @group.id } }
    assert_response :success
    
    tag = JSON.parse(response.body)['tags'].find { |t| t['name'] == 'newtag' }
    assert_equal @group.id, tag['group_id']
    assert_equal '#ccc', tag['color']
    assert_equal 0, tag['taggings_count']
    assert_equal 0, tag['org_taggings_count']
  end

  test "update updates a tag" do
    tag = Tag.find_by(group_id: @group.id, name: 'apple')
    put :update, params: { id: tag.id, tag: { name: 'apple2', color: '#aaa' } }
    assert_response :success
    
    tag_attrs = JSON.parse(response.body)['tags'][0]
    assert_equal 'apple2', tag_attrs['name']
    assert_equal @group.id, tag_attrs['group_id']
    assert_equal '#aaa', tag_attrs['color']
    assert_equal 2, tag_attrs['taggings_count']
    assert_equal 4, tag_attrs['org_taggings_count']
  end

  test "update parent tag updates subgroup tag" do
    tag = Tag.find_by(group_id: @group.id, name: 'apple')
    put :update, params: { id: tag.id, tag: { name: 'apple2', color: '#aaa' } }
    assert_response :success
    
    assert_equal ['apple2', 'banana'], @discussion.reload.tags
    assert_equal ['apple2', 'banana'], @sub_discussion.reload.tags
    assert_equal ['apple2', 'banana'], @poll.reload.tags
    assert_equal ['apple2', 'banana'], @sub_poll.reload.tags
    assert_equal 4, Tag.where(group_id: @group.parent_or_self.id_and_subgroup_ids).count
  end

  test "merge parent tag into existing tag" do
    tag = Tag.find_by(group_id: @group.id, name: 'apple')
    put :update, params: { id: tag.id, tag: { name: 'banana', color: '#aaa' } }
    assert_response :success
    
    assert_equal ['banana'], @discussion.reload.tags
    assert_equal ['banana'], @sub_discussion.reload.tags
    assert_equal ['banana'], @poll.reload.tags
    assert_equal ['banana'], @sub_poll.reload.tags
    assert_equal 2, Tag.where(group_id: @group.parent_or_self.id_and_subgroup_ids).count
  end

  test "update subgroup tag does not update parent tag" do
    tag = Tag.find_by(group_id: @subgroup.id, name: 'apple')
    put :update, params: { id: tag.id, tag: { name: 'apple2', color: '#aaa' } }
    assert_response :success
    
    assert_equal ['apple', 'banana'], @discussion.reload.tags
    assert_equal ['apple2', 'banana'], @sub_discussion.reload.tags
    assert_equal ['apple', 'banana'], @poll.reload.tags
    assert_equal ['apple2', 'banana'], @sub_poll.reload.tags
    assert_equal 2, Tag.find_by(group_id: @group.id, name: 'apple').taggings_count
    assert_equal 2, Tag.find_by(group_id: @group.id, name: 'apple').org_taggings_count
    assert_equal 2, Tag.find_by(group_id: @group.id, name: 'apple2').org_taggings_count
    assert_equal 2, Tag.find_by(group_id: @subgroup.id, name: 'apple2').taggings_count
  end

  test "merge subgroup tag" do
    tag = Tag.find_by(group_id: @subgroup.id, name: 'apple')
    put :update, params: { id: tag.id, tag: { name: 'banana', color: '#aaa' } }
    
    assert_equal ['apple', 'banana'], @discussion.reload.tags
    assert_equal ['banana'], @sub_discussion.reload.tags
    assert_equal ['apple', 'banana'], @poll.reload.tags
    assert_equal ['banana'], @sub_poll.reload.tags
    assert_equal 3, Tag.where(group_id: @group.parent_or_self.id_and_subgroup_ids).count
  end
end
