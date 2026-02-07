require 'test_helper'

class GroupPrivacyTest < ActiveSupport::TestCase
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

  test "closed subgroup of secret parent is visible_to_parent_members" do
    secret_parent = Group.create!(name: "Secret Parent #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group = Group.create!(name: "Closed Sub #{SecureRandom.hex(4)}", parent: secret_parent, group_privacy: 'closed')
    assert_equal false, group.is_visible_to_public
    assert_equal true, group.is_visible_to_parent_members
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
