require 'test_helper'

class Api::V1::TagsControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @group = groups(:group)
    @subgroup = groups(:subgroup)

    @discussion = DiscussionService.create(params: { title: "Tags #{SecureRandom.hex(4)}", group_id: @group.id, tags: ['apple', 'banana'] }, actor: @admin)
    @poll = PollService.create(params: {
      title: "Test Poll",
      poll_type: "proposal",
      group_id: @group.id,
      specified_voters_only: true,
      closing_at: 5.days.from_now,
      poll_option_names: ["Agree", "Disagree"],
      tags: ['apple', 'banana']
    }, actor: @admin)

    @sub_discussion = DiscussionService.create(params: { title: "SubTags #{SecureRandom.hex(4)}", group_id: @subgroup.id, tags: ['apple', 'banana'] }, actor: @admin)
    @sub_poll = PollService.create(params: {
      title: "Subgroup Poll",
      poll_type: "proposal",
      group_id: @subgroup.id,
      specified_voters_only: true,
      closing_at: 5.days.from_now,
      poll_option_names: ["Agree", "Disagree"],
      tags: ['apple', 'banana']
    }, actor: @admin)

    TagService.update_group_and_org_tags(@group.id)

    sign_in @admin
  end

  test "create stores tag metadata on the parent group" do
    post :create, params: { tag: { name: 'newtag', color: '#ccc', group_id: @subgroup.id } }
    assert_response :success

    tag = JSON.parse(response.body)['tags'].find { |t| t['name'] == 'newtag' }
    assert_equal @group.id, tag['group_id']
    assert_equal '#ccc', tag['color']
    assert_not Tag.exists?(group_id: @subgroup.id, name: 'newtag')
  end

  test "subgroup admin cannot manage tag metadata" do
    memberships(:user_subgroup_membership).update!(admin: true)
    sign_in users(:user)

    post :create, params: { tag: { name: 'subtag', color: '#ccc', group_id: @subgroup.id } }

    assert_response :forbidden
  end

  test "update renames a tag across the parent group and subgroups" do
    tag = Tag.find_by!(group_id: @group.id, name: 'apple')

    put :update, params: { id: tag.id, tag: { name: 'apple2', color: '#aaa' } }
    assert_response :success

    tag_attrs = JSON.parse(response.body)['tags'][0]
    assert_equal 'apple2', tag_attrs['name']
    assert_equal @group.id, tag_attrs['group_id']
    assert_equal '#aaa', tag_attrs['color']

    assert_equal ['apple2', 'banana'], @discussion.topic.reload.tags
    assert_equal ['apple2', 'banana'], @sub_discussion.topic.reload.tags
    assert_equal ['apple2', 'banana'], @poll.topic.reload.tags
    assert_equal ['apple2', 'banana'], @sub_poll.topic.reload.tags
    assert_not Tag.exists?(group_id: @subgroup.id, name: 'apple2')
  end

  test "update renames a tag when only case changes" do
    tag = Tag.find_by!(group_id: @group.id, name: 'apple')

    put :update, params: { id: tag.id, tag: { name: 'Apple', color: '#aaa' } }
    assert_response :success

    tag_attrs = JSON.parse(response.body)['tags'][0]
    assert_equal 'Apple', tag_attrs['name']
    assert_equal '#aaa', tag_attrs['color']

    assert_equal ['Apple', 'banana'], @discussion.topic.reload.tags
    assert_equal ['Apple', 'banana'], @sub_discussion.topic.reload.tags
    assert_equal ['Apple', 'banana'], @poll.topic.reload.tags
    assert_equal ['Apple', 'banana'], @sub_poll.topic.reload.tags
    assert_not_includes Tag.where(group_id: @group.id).map(&:name), 'apple'
  end

  test "merge tag into existing tag across the parent group and subgroups" do
    tag = Tag.find_by!(group_id: @group.id, name: 'apple')

    put :update, params: { id: tag.id, tag: { name: 'banana', color: '#aaa' } }
    assert_response :success

    assert_equal ['banana'], @discussion.topic.reload.tags
    assert_equal ['banana'], @sub_discussion.topic.reload.tags
    assert_equal ['banana'], @poll.topic.reload.tags
    assert_equal ['banana'], @sub_poll.topic.reload.tags
    assert_equal ['banana'], Tag.where(group_id: @group.id).pluck(:name).sort
  end

  test "destroy removes a tag from parent group and subgroup topics" do
    tag = Tag.find_by!(group_id: @group.id, name: 'apple')

    delete :destroy, params: { id: tag.id }
    assert_response :success

    assert_equal ['banana'], @discussion.topic.reload.tags
    assert_equal ['banana'], @sub_discussion.topic.reload.tags
    assert_equal ['banana'], @poll.topic.reload.tags
    assert_equal ['banana'], @sub_poll.topic.reload.tags
    assert_not Tag.exists?(group_id: @group.id, name: 'apple')
    assert JSON.parse(response.body)['tags'].none? { |t| t['name'] == 'apple' }
  end

  test "destroy removes legacy tag metadata with unnormalized whitespace" do
    tag = Tag.find_by!(group_id: @group.id, name: 'apple')
    Tag.where(id: tag.id).update_all(name: 'apple ')

    delete :destroy, params: { id: tag.id }
    assert_response :success

    assert_equal ['banana'], @discussion.topic.reload.tags
    assert_equal ['banana'], @sub_discussion.topic.reload.tags
    assert_not Tag.exists?(id: tag.id)
    assert JSON.parse(response.body)['tags'].none? { |t| t['id'] == tag.id }
  end
end
