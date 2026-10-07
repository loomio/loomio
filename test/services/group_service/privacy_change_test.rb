require 'test_helper'

class GroupService::PrivacyChangeTest < ActiveSupport::TestCase
  test "hiding a parent also restricts public descendants and their threads" do
    parent = groups(:group)
    parent.update!(group_privacy: 'closed')
    child = groups(:parent_join_subgroup)
    child.update!(group_privacy: 'open')
    descendant = Group.create!(name: 'Nested working group', parent: child, group_privacy: 'open')
    topic = topics(:discussion_topic)
    topic.update!(group: descendant, private: false)

    GroupService.update(group: parent, params: {group_privacy: 'secret'}, actor: users(:admin))

    assert_equal 'parent_members', child.reload.group_privacy
    assert_equal 'parent_members', descendant.reload.group_privacy
    assert topic.reload.private?
    assert_not LoggedOutUser.new.can?(:show, descendant)
    assert_not LoggedOutUser.new.can?(:show, topic.topicable)
  end

  test "hiding a parent preserves secret and already parent visible subgroup boundaries" do
    parent = groups(:group)
    parent.update!(group_privacy: 'closed')
    internal = groups(:parent_join_subgroup)
    internal.update!(parent_members_can_see_discussions: true)
    secret = groups(:subgroup)
    secret.update!(group_privacy: 'secret')
    public_subgroup = Group.create!(name: 'Public work', parent: parent, group_privacy: 'closed', membership_granted_upon: 'request')

    GroupService.update(group: parent, params: {group_privacy: 'secret'}, actor: users(:admin))

    assert_equal 'secret', secret.reload.group_privacy
    assert_not users(:member_normal).can?(:show, secret)
    assert_equal 'parent_members', internal.reload.group_privacy
    assert internal.parent_members_can_see_discussions?
    assert_equal 'request', internal.membership_granted_upon
    assert_equal 'parent_members', public_subgroup.reload.group_privacy
    assert_equal 'request', public_subgroup.membership_granted_upon
    assert_not LoggedOutUser.new.can?(:show, public_subgroup)
    assert_not users(:alien).can?(:show, public_subgroup)
  end

  test "privacy propagation failure rolls back parent subgroups and topics without broadcasting" do
    parent = groups(:group)
    parent.update!(group_privacy: 'open')
    subgroup = groups(:parent_join_subgroup)
    subgroup.update!(group_privacy: 'open')
    topic = topics(:discussion_topic)
    topic.update!(private: false)
    build_change = GroupService::PrivacyChange.method(:new)
    failing_change = ->(group) do
      change = build_change.call(group)
      commit = change.method(:commit!)
      change.define_singleton_method(:commit!) do
        commit.call
        raise 'Privacy propagation failed'
      end
      change
    end

    EventBus.stub(:broadcast, ->(*) { flunk 'Rolled back privacy was broadcast' }) do
      GroupService::PrivacyChange.stub(:new, failing_change) do
        assert_raises RuntimeError do
          GroupService.update(group: parent, params: {group_privacy: 'secret'}, actor: users(:admin))
        end
      end
    end

    assert_equal 'open', parent.reload.group_privacy
    assert_equal 'open', subgroup.reload.group_privacy
    assert_not topic.reload.private?
  end

  test "makes discussions in group and subgroups private when is_visible_to_public changes to false" do
    # Create a user to author discussions
    author = users(:user)

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
    DiscussionService.create(params: { title: "Test 1", group_id: group.id, private: false }, actor: author)
    DiscussionService.create(params: { title: "Test 2", group_id: subgroup.id, private: false }, actor: author)
    DiscussionService.create(params: { title: "Test 3", group_id: other_subgroup.id, private: false }, actor: author)

    # Change privacy
    group.is_visible_to_public = false
    privacy_change = GroupService::PrivacyChange.new(group)
    group.save!
    privacy_change.commit!

    # Verify discussions are now private
    assert Topic.where(group_id: group.id_and_subgroup_ids).all?(&:private?)
  end

  test "makes public subgroups visible only to parent members when the parent is hidden" do
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
    assert group.subgroups.all? { |g| g.group_privacy == 'parent_members' }
    assert group.subgroups.all?(&:is_hidden_from_public?)
    assert group.subgroups.all?(&:is_visible_to_parent_members?)
  end

  test "makes discussions private when discussion_privacy_options changes to private_only" do
    # Create a user to author discussions
    author = users(:user)

    # Create a group that allows public discussions
    group = Group.create!(
      name: 'Open Group',
      group_privacy: 'open',
      handle: 'closedgroup'
    )
    group.add_member!(author)

    DiscussionService.create(params: { title: "Test", group_id: group.id, private: false }, actor: author)

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
    author = users(:user)

    # Create a secret group with private discussions
    group = Group.create!(
      name: 'Secret Group',
      group_privacy: 'secret',
      handle: 'secretgroup'
    )
    group.add_member!(author)

    DiscussionService.create(params: { title: "Test", group_id: group.id, private: true }, actor: author)

    # Change to open
    group.group_privacy = 'open'
    privacy_change = GroupService::PrivacyChange.new(group)
    group.save!
    privacy_change.commit!

    # Verify discussions are public
    assert group.topics.all?(&:public?)
  end
end
