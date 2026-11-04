require 'test_helper'

class GroupPrivacyTest < ActiveSupport::TestCase
  test "public subgroup flags cannot bypass a hidden parent boundary" do
    subgroup = groups(:parent_join_subgroup)
    %w[public_only private_only public_or_private].each do |thread_privacy|
      subgroup.assign_attributes(is_visible_to_public: true, discussion_privacy_options: thread_privacy)
      assert_not subgroup.valid?
      assert subgroup.errors[:group_privacy].present?
    end
    %w[open closed].each do |privacy|
      subgroup.group_privacy = privacy
      assert_not subgroup.valid?
    end

    %w[parent_members secret].each do |privacy|
      subgroup.group_privacy = privacy
      assert subgroup.valid?
      assert_not subgroup.is_visible_to_public?
    end
  end

  test "parent visible privacy uses existing fields independently of parent privacy and joining" do
    subgroup = groups(:parent_join_subgroup)
    parent = subgroup.parent

    %w[open closed secret].each do |privacy|
      parent.update!(group_privacy: privacy)
      subgroup.update!(group_privacy: 'parent_members')
      assert_equal 'parent_members', subgroup.reload.group_privacy
      assert_not subgroup.is_visible_to_public?
      assert subgroup.is_visible_to_parent_members?
      assert_equal 'private_only', subgroup.discussion_privacy_options
      assert_equal 'request', subgroup.membership_granted_upon
    end
  end

  test "a root group cannot use parent visible privacy" do
    group = groups(:group)
    group.group_privacy = 'parent_members'
    assert_not group.valid?
    assert group.errors[:is_visible_to_parent_members].present?
  end

  test "existing hidden subgroup flags have an explicit parent visible label" do
    subgroup = groups(:parent_join_subgroup)
    assert_equal 'parent_members', subgroup.group_privacy
    assert subgroup.valid?
  end

  test "changing the parent to public preserves the subgroup audience and private threads" do
    subgroup = groups(:parent_join_subgroup)
    subgroup.parent.update!(group_privacy: 'closed')
    assert_equal 'parent_members', subgroup.reload.group_privacy
    assert_equal 'private_only', subgroup.discussion_privacy_options
    assert_not subgroup.is_visible_to_public?
  end

  test "secret privacy clears parent thread access and public privacy clears parent visibility" do
    subgroup = groups(:parent_join_subgroup)
    subgroup.parent.update!(group_privacy: 'closed')
    subgroup.update!(parent_members_can_see_discussions: true)
    subgroup.update!(group_privacy: 'secret')
    assert_not subgroup.parent_members_can_see_discussions?
    assert_not subgroup.is_visible_to_parent_members?

    subgroup.update!(group_privacy: 'open')
    assert_equal 'open', subgroup.group_privacy
    assert_not subgroup.is_visible_to_parent_members?
  end

  test "closed subgroups retain immediate joining until made secret" do
    subgroup = groups(:parent_join_subgroup)
    subgroup.parent.update!(group_privacy: 'closed')
    assert subgroup.valid?
    assert subgroup.membership_granted_upon_request?

    subgroup.group_privacy = 'closed'
    assert subgroup.valid?
    assert_equal 'request', subgroup.membership_granted_upon

    subgroup.group_privacy = 'open'
    assert subgroup.valid?
    assert_equal 'request', subgroup.membership_granted_upon

    subgroup.group_privacy = 'secret'
    assert_equal 'invitation', subgroup.membership_granted_upon
  end

  # group_privacy getter
  test "gets values for open correctly" do
    group = Group.new(is_visible_to_public: true, discussion_privacy_options: 'public_only')
    assert_equal 'open', group.group_privacy
  end

  test "gets values for closed correctly" do
    group = Group.new(is_visible_to_public: true, discussion_privacy_options: 'public_or_private')
    assert_equal 'closed', group.group_privacy

    group.discussion_privacy_options = 'private_only'
    assert_equal 'closed', group.group_privacy
  end

  test "gets values for secret correctly" do
    group = Group.new(is_visible_to_public: false)
    assert_equal 'secret', group.group_privacy
  end

  # group_privacy= open
  test "open sets visible to public and public discussions only" do
    group = Group.new(is_visible_to_public: false, discussion_privacy_options: 'public_or_private')
    group.group_privacy = 'open'
    assert_equal true, group.is_visible_to_public
    assert_equal 'public_only', group.discussion_privacy_options
  end

  test "open allows request membership_granted_upon" do
    group = Group.new
    group.membership_granted_upon = 'request'
    group.group_privacy = 'open'
    assert_equal 'request', group.membership_granted_upon
  end

  test "open allows approval membership_granted_upon" do
    group = Group.new
    group.membership_granted_upon = 'approval'
    group.group_privacy = 'open'
    assert_equal 'approval', group.membership_granted_upon
  end

  test "open does not allow invitation membership_granted_upon" do
    group = Group.new
    group.membership_granted_upon = 'bla'
    group.group_privacy = 'open'
    assert_equal 'approval', group.membership_granted_upon
  end

  # group_privacy= closed
  test "closed sets visible to public and private discussions" do
    group = Group.new(
      membership_granted_upon: 'approval',
      is_visible_to_public: false,
      discussion_privacy_options: 'public_only'
    )
    group.group_privacy = 'closed'
    assert_equal true, group.is_visible_to_public
    assert_equal 'private_only', group.discussion_privacy_options
    assert_equal 'approval', group.membership_granted_upon
  end

  test "closed allows public_or_private discussion_privacy_options" do
    group = Group.new
    group.discussion_privacy_options = 'public_or_private'
    group.group_privacy = 'closed'
    assert_equal 'public_or_private', group.discussion_privacy_options
  end

  test "closed allows private_only discussion_privacy_options" do
    group = Group.new
    group.discussion_privacy_options = 'private_only'
    group.group_privacy = 'closed'
    assert_equal 'private_only', group.discussion_privacy_options
  end

  test "closed does not allow public_only discussion_privacy_options" do
    group = Group.new
    group.discussion_privacy_options = 'public_only'
    group.group_privacy = 'closed'
    assert_equal 'private_only', group.discussion_privacy_options
  end

  test "closed subgroup of secret parent is invalid" do
    subgroup = groups(:parent_join_subgroup)
    subgroup.group_privacy = 'closed'
    assert_not subgroup.valid?
    assert subgroup.errors[:group_privacy].present?
  end

  # group_privacy= secret
  test "secret sets not visible, private discussions, invitation only" do
    group = Group.new(
      membership_granted_upon: 'approval',
      is_visible_to_public: true,
      is_visible_to_parent_members: true,
      discussion_privacy_options: 'public_only'
    )
    group.group_privacy = 'secret'
    assert_equal false, group.is_visible_to_public
    assert_equal 'private_only', group.discussion_privacy_options
    assert_equal 'invitation', group.membership_granted_upon
    assert_equal false, group.is_visible_to_parent_members
  end
end
