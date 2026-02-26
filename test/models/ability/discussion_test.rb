require 'test_helper'

class Ability::DiscussionTest < ActiveSupport::TestCase
  # Discussion without group
  test "discussion without group as admin" do
    user = users(:user)
    other = users(:alien)
    discussion = DiscussionService.create(params: discussion_params, actor: other)
    discussion.topic.topic_readers.create!(user_id: user.id, admin: true, guest: true, inviter_id: other.id)
    assert user.can?(:announce, discussion.topic)
    assert user.can?(:add_guests, discussion.topic)
    assert user.can?(:update, discussion)
  end

  test "discussion without group as member" do
    user = users(:user)
    other = users(:alien)
    discussion = DiscussionService.create(params: discussion_params, actor: other)
    discussion.topic.topic_readers.create!(user_id: user.id, admin: false, guest: true, inviter_id: other.id)
    assert_not user.can?(:announce, discussion)
    assert_not user.can?(:add_guests, discussion)
    assert user.can?(:update, discussion)
  end

  test "discussion without group as unrelated" do
    user = users(:user)
    other = users(:alien)
    discussion = DiscussionService.create(params: discussion_params, actor: other)
    assert_not user.can?(:announce, discussion)
    assert_not user.can?(:add_guests, discussion)
    assert_not user.can?(:update, discussion)
  end

  # Discussion in group - as group admin
  test "group admin can manage discussion" do
    admin = users(:admin)
    group = groups(:group)
    discussion = DiscussionService.create(params: discussion_params(group_id: group.id), actor: admin)
    assert admin.can?(:add_members, discussion.topic)
    assert admin.can?(:announce, discussion.topic)
    assert admin.can?(:add_guests, discussion.topic)
  end

  # Discussion in group - as group member, topic admin
  test "group member topic admin with members_can_add_guests true" do
    user = users(:user)
    group = groups(:group)
    group.update_columns(members_can_add_guests: true)
    discussion = DiscussionService.create(params: discussion_params(group_id: group.id), actor: users(:admin))
    discussion.topic.topic_readers.find_or_create_by!(user: user).update!(admin: true)
    assert user.can?(:add_guests, discussion.topic)
  end

  test "group member topic admin with members_can_add_guests false" do
    user = users(:user)
    group = groups(:group)
    group.update_columns(members_can_add_guests: false)
    discussion = DiscussionService.create(params: discussion_params(group_id: group.id), actor: users(:admin))
    discussion.topic.topic_readers.find_or_create_by!(user: user).update!(admin: true)
    assert_not user.can?(:add_guests, discussion)
  end

  test "group member topic admin with members_can_announce true" do
    user = users(:user)
    group = groups(:group)
    group.update_columns(members_can_announce: true)
    discussion = DiscussionService.create(params: discussion_params(group_id: group.id), actor: users(:admin))
    discussion.topic.topic_readers.find_or_create_by!(user: user).update!(admin: true)
    assert user.can?(:announce, discussion)
  end

  test "group member topic admin with members_can_announce false" do
    user = users(:user)
    group = groups(:group)
    group.update_columns(members_can_announce: false)
    discussion = DiscussionService.create(params: discussion_params(group_id: group.id), actor: users(:admin))
    discussion.topic.topic_readers.find_or_create_by!(user: user).update!(admin: true)
    assert_not user.can?(:announce, discussion)
  end

  # Discussion in group - as group member (not topic admin)
  test "group member with members_can_add_guests true" do
    user = users(:user)
    group = groups(:group)
    group.update_columns(members_can_add_guests: true)
    discussion = DiscussionService.create(params: discussion_params(group_id: group.id), actor: users(:admin))
    assert user.can?(:add_guests, discussion.topic)
  end

  test "group member with members_can_announce true" do
    user = users(:user)
    group = groups(:group)
    group.update_columns(members_can_announce: true)
    discussion = DiscussionService.create(params: discussion_params(group_id: group.id), actor: users(:admin))
    assert user.can?(:announce, discussion)
  end

  test "group member with members_can_edit_discussions true" do
    user = users(:user)
    group = groups(:group)
    group.update_columns(members_can_edit_discussions: true)
    discussion = DiscussionService.create(params: discussion_params(group_id: group.id), actor: users(:admin))
    assert user.can?(:update, discussion)
  end

  test "group member with members_can_edit_discussions false" do
    user = users(:user)
    group = groups(:group)
    group.update_columns(members_can_edit_discussions: false)
    discussion = DiscussionService.create(params: discussion_params(group_id: group.id), actor: users(:admin))
    assert_not user.can?(:update, discussion)
  end

  private

  def discussion_params(**overrides)
    {
      title: "Discussion #{SecureRandom.hex(4)}",
      private: true
    }.merge(overrides)
  end
end
