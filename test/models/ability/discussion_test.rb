require 'test_helper'

class Ability::DiscussionTest < ActiveSupport::TestCase
  def can?(action, subject)
    @ability.can?(action, subject)
  end

  def cannot?(action, subject)
    !@ability.can?(action, subject)
  end

  setup do
    @actor = users(:normal_user)
    @ability = Ability::Base.new(@actor)
  end

  # Discussion without group
  test "discussion without group as admin" do
    author = User.create!(name: "DA #{SecureRandom.hex(4)}", email: "da_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    discussion = Discussion.create!(title: "No group disc", author: author, private: true)
    discussion.discussion_readers.create!(user_id: @actor.id, admin: true, guest: true, inviter_id: @actor.id)
    assert can?(:announce, discussion)
    assert can?(:add_guests, discussion)
    assert can?(:update, discussion)
  end

  test "discussion without group as member" do
    author = User.create!(name: "DA #{SecureRandom.hex(4)}", email: "da_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    discussion = Discussion.create!(title: "No group disc", author: author, private: true)
    discussion.discussion_readers.create!(user_id: @actor.id, admin: false, guest: true, inviter_id: @actor.id)
    assert cannot?(:announce, discussion)
    assert cannot?(:add_guests, discussion)
    assert can?(:update, discussion)
  end

  test "discussion without group as unrelated" do
    author = User.create!(name: "DA #{SecureRandom.hex(4)}", email: "da_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    discussion = Discussion.create!(title: "No group disc", author: author, private: true)
    assert cannot?(:announce, discussion)
    assert cannot?(:add_guests, discussion)
    assert cannot?(:update, discussion)
  end

  # Discussion in group - as group admin
  test "group admin can manage discussion" do
    group = Group.create!(name: "DGrp #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.add_admin!(@actor)
    discussion = create_discussion(group: group, author: @actor)
    assert can?(:add_members, discussion)
    assert can?(:announce, discussion)
    assert can?(:add_guests, discussion)
  end

  # Discussion in group - as group member, discussion admin
  test "group member discussion admin with members_can_add_guests true" do
    group, discussion = create_group_and_discussion(members_can_add_guests: true)
    group.add_member!(@actor)
    discussion.discussion_readers.create!(user_id: @actor.id, admin: true)
    assert can?(:add_guests, discussion)
  end

  test "group member discussion admin with members_can_add_guests false" do
    group, discussion = create_group_and_discussion(members_can_add_guests: false)
    group.add_member!(@actor)
    discussion.discussion_readers.create!(user_id: @actor.id, admin: true)
    assert cannot?(:add_guests, discussion)
  end

  test "group member discussion admin with members_can_announce true" do
    group, discussion = create_group_and_discussion(members_can_announce: true)
    group.add_member!(@actor)
    discussion.discussion_readers.create!(user_id: @actor.id, admin: true)
    assert can?(:announce, discussion)
  end

  test "group member discussion admin with members_can_announce false" do
    group, discussion = create_group_and_discussion(members_can_announce: false)
    group.add_member!(@actor)
    discussion.discussion_readers.create!(user_id: @actor.id, admin: true)
    assert cannot?(:announce, discussion)
  end

  # Discussion in group - as group member (not discussion admin)
  test "group member with members_can_add_guests true" do
    group, discussion = create_group_and_discussion(members_can_add_guests: true)
    group.add_member!(@actor)
    assert can?(:add_guests, discussion)
  end

  test "group member with members_can_announce true" do
    group, discussion = create_group_and_discussion(members_can_announce: true)
    group.add_member!(@actor)
    assert can?(:announce, discussion)
  end

  test "group member with members_can_edit_discussions true" do
    group, discussion = create_group_and_discussion(members_can_edit_discussions: true)
    group.add_member!(@actor)
    assert can?(:update, discussion)
  end

  test "group member with members_can_edit_discussions false" do
    group, discussion = create_group_and_discussion(members_can_edit_discussions: false)
    group.add_member!(@actor)
    assert cannot?(:update, discussion)
  end

  private

  def create_group_and_discussion(**group_options)
    author = User.create!(name: "DA #{SecureRandom.hex(4)}", email: "da_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    group = Group.create!({ name: "DG #{SecureRandom.hex(4)}", group_privacy: 'secret' }.merge(group_options))
    group.add_admin!(author)
    discussion = create_discussion(group: group, author: author)
    [group, discussion]
  end
end
