require 'test_helper'

class Ability::GroupAccessTest < ActiveSupport::TestCase
  test "group invitation tokens reveal only their own group's metadata" do
    group = topics(:discussion_topic).group
    assert_equal 'secret', group.group_privacy
    actor = users(:alien_loud)
    assert_not group.members.exists?(actor.id)

    [nil, groups(:alien_group).token, 'invalid-group-token'].each do |token|
      actor.group_token = token
      assert_not actor.can?(:show, group), token.inspect
      assert_not LoggedOutUser.new(params: {group_token: token}).can?(:show, group), token.inspect
    end

    actor.group_token = group.token
    [actor, LoggedOutUser.new(params: {group_token: group.token})].each do |bearer|
      assert bearer.can?(:show, group)
      assert_not bearer.can?(:see_private_content, group)
      assert_not bearer.can?(:subscribe_to, group)
    end

    group.discard!
    assert_not actor.can?(:show, group)
  end

  test "membership invitation tokens must be pending and belong to the requested group" do
    group = topics(:discussion_topic).group
    invitation = memberships(:member_normal_membership)
    invitation.update!(accepted_at: nil)
    actor = users(:alien_loud)

    [nil, memberships(:alien_group_membership).token, 'invalid-membership-token'].each do |token|
      actor.membership_token = token
      assert_not actor.can?(:show, group), token.inspect
    end

    actor.membership_token = invitation.token
    assert actor.can?(:show, group)
    assert LoggedOutUser.new(params: {membership_token: invitation.token}).can?(:show, group)
    assert_not actor.can?(:see_private_content, group)

    invitation.update!(accepted_at: Time.current)
    assert_not actor.can?(:show, group)
    invitation.update!(accepted_at: nil, revoked_at: Time.current)
    assert_not actor.can?(:show, group)
  end

  test "private group content distinguishes members, parent members, and public readers" do
    group = topics(:discussion_topic).group
    subgroup = groups(:parent_join_subgroup)
    member = users(:member_normal)
    outsider = users(:alien_loud)

    [group, subgroup].each do |record|
      %i[see_private_content subscribe_to].each do |action|
        assert member.can?(action, record)
        assert_not outsider.can?(action, record)
        assert_not LoggedOutUser.new.can?(action, record)
      end
    end

    subgroup.update!(is_visible_to_parent_members: false)
    assert_not member.can?(:see_private_content, subgroup)
    assert users(:subgroup_user).can?(:see_private_content, subgroup)

    group.update!(group_privacy: 'closed')
    assert outsider.can?(:show, group)
    assert_not outsider.can?(:see_private_content, group)
    group.update!(group_privacy: 'open')
    assert outsider.can?(:see_private_content, group)
    assert LoggedOutUser.new.can?(:see_private_content, group)
    group.discard!
    assert_not outsider.can?(:see_private_content, group)
  end

  test "move destinations require verified coordination or permitted group membership" do
    group = topics(:discussion_topic).group
    coordinator = users(:member_quiet)
    member = users(:member_normal)
    group.add_admin!(coordinator)
    group.update!(members_can_start_discussions: false)

    assert coordinator.can?(:move_discussions_to, group)
    assert_not member.can?(:move_discussions_to, group)

    group.update!(members_can_start_discussions: true)
    assert member.can?(:move_discussions_to, group)
    [users(:alien_loud), users(:guest_admin_normal), LoggedOutUser.new].each do |outsider|
      assert_not outsider.can?(:move_discussions_to, group)
    end

    [coordinator, member].each do |actor|
      actor.update!(email_verified: false)
      assert_not actor.can?(:move_discussions_to, group)
    end
  end
end
