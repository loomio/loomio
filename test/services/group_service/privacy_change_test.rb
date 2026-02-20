require 'test_helper'

class GroupService::PrivacyChangeTest < ActiveSupport::TestCase
  test "makes discussions in group and subgroups private when is_visible_to_public changes to false" do
    # Create a user to author discussions
    author = users(:normal_user)

    # Create an open group with public discussions
    group = Group.create!(
      name: 'Open Group',
      group_privacy: 'open',
      is_visible_to_public: true,
      handle: 'opengroup'
    )
    group.add_member!(author)

    subgroup = Group.create!(
      name: 'Subgroup',
      parent: group,
      group_privacy: 'open',
      is_visible_to_public: true,
      handle: 'opengroup-subgroup'
    )
    subgroup.add_member!(author)

    other_subgroup = Group.create!(
      name: 'Other Subgroup',
      parent: group,
      group_privacy: 'open',
      is_visible_to_public: true,
      handle: 'opengroup-othersubgroup'
    )
    other_subgroup.add_member!(author)

    # Create public discussions
    create_discussion(group: group, author: author, private: false)
    create_discussion(group: subgroup, author: author, private: false)
    create_discussion(group: other_subgroup, author: author, private: false)

    # Change privacy
    group.is_visible_to_public = false
    privacy_change = GroupService::PrivacyChange.new(group)
    group.save!
    privacy_change.commit!

    # Verify discussions are now private
    assert Topic.where(group_id: group.id_and_subgroup_ids).all?(&:private?)
  end

  test "makes all public subgroups closed and visible to parent members when is_visible_to_public changes to false" do
    # Create an open group with subgroups
    group = Group.create!(
      name: 'Open Group',
      group_privacy: 'open',
      is_visible_to_public: true,
      handle: 'opengroup2'
    )

    subgroup = Group.create!(
      name: 'Subgroup',
      parent: group,
      group_privacy: 'open',
      is_visible_to_public: true,
      handle: 'opengroup2-subgroup'
    )

    other_subgroup = Group.create!(
      name: 'Other Subgroup',
      parent: group,
      group_privacy: 'open',
      is_visible_to_public: true,
      handle: 'opengroup2-othersubgroup'
    )

    # Change privacy
    group.is_visible_to_public = false
    privacy_change = GroupService::PrivacyChange.new(group)
    group.save!
    privacy_change.commit!

    # Verify subgroups are closed and visible to parent
    assert group.subgroups.all? { |g| g.group_privacy == 'closed' }
    assert group.subgroups.all?(&:is_hidden_from_public?)
    assert group.subgroups.all?(&:is_visible_to_parent_members?)
  end

  test "makes discussions private when discussion_privacy_options changes to private_only" do
    # Create a user to author discussions
    author = users(:normal_user)

    # Create a group that allows public discussions
    group = Group.create!(
      name: 'Open Group',
      group_privacy: 'open',
      handle: 'closedgroup'
    )
    group.add_member!(author)

    create_discussion(group: group, author: author, private: false)

    # Change privacy options
    group.discussion_privacy_options = 'private_only'
    privacy_change = GroupService::PrivacyChange.new(group)
    group.save!
    privacy_change.commit!

    # Verify discussions are private
    assert group.topics.all?(&:private?)
  end

  test "makes discussions public when discussion_privacy_options changes to public_only" do
    # Create a user to author discussions
    author = users(:normal_user)

    # Create a secret group with private discussions
    group = Group.create!(
      name: 'Secret Group',
      group_privacy: 'secret',
      handle: 'secretgroup'
    )
    group.add_member!(author)

    create_discussion(group: group, author: author, private: true)

    # Change to open
    group.group_privacy = 'open'
    privacy_change = GroupService::PrivacyChange.new(group)
    group.save!
    privacy_change.commit!

    # Verify discussions are public
    assert group.topics.all?(&:public?)
  end
end
