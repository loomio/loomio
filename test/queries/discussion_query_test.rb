require 'test_helper'

class DiscussionQueryTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @author = users(:admin)
    @group = groups(:group)
    # discussion_author is already admin, normal_user is already member via fixtures
    @discussion = discussions(:discussion)
    ActionMailer::Base.deliveries.clear
  end

  # -- Logged out --

  test "logged out shows groups visible to public if no groups specified" do
    pub_group1 = Group.new(name: "PubGroup1 #{SecureRandom.hex(4)}", is_visible_to_public: true, discussion_privacy_options: 'public_or_private')
    pub_group1.save(validate: false)
    pub_group2 = Group.new(name: "PubGroup2 #{SecureRandom.hex(4)}", is_visible_to_public: true, discussion_privacy_options: 'public_or_private')
    pub_group2.save(validate: false)
    priv_group = Group.new(name: "PrivGroup #{SecureRandom.hex(4)}", is_visible_to_public: false)
    priv_group.save(validate: false)

    hex = SecureRandom.hex(4)
    pub_author = User.create!(name: "pubauth#{hex}", email: "pubauth#{hex}@example.com", username: "pubauth#{hex}")
    pub_group1.add_admin!(pub_author)
    pub_group2.add_admin!(pub_author)
    priv_group.add_admin!(pub_author)

    # Create discussions without DiscussionService.create to bypass authorization
    pub_disc1 = DiscussionService.build(params: { title: "Pub1", group_id: pub_group1.id, private: false, description_format: "html" }, actor: pub_author)
    pub_disc1.save(validate: false)
    pub_disc1.create_missing_created_event!
    pub_disc2 = DiscussionService.build(params: { title: "Pub2", group_id: pub_group2.id, private: false, description_format: "html" }, actor: pub_author)
    pub_disc2.save(validate: false)
    pub_disc2.create_missing_created_event!
    priv_disc = DiscussionService.build(params: { title: "Priv", group_id: priv_group.id, private: true, description_format: "html" }, actor: pub_author)
    priv_disc.save(validate: false)
    priv_disc.create_missing_created_event!

    query = DiscussionQuery.visible_to
    assert_includes query, pub_disc1
    assert_includes query, pub_disc2
    refute_includes query, priv_disc
  end

  test "logged out shows specified groups if they are public" do
    pub_group = Group.new(name: "PubGroup #{SecureRandom.hex(4)}", is_visible_to_public: true, discussion_privacy_options: 'public_or_private')
    pub_group.save(validate: false)
    hex = SecureRandom.hex(4)
    pub_author = User.create!(name: "pubauth#{hex}", email: "pubauth#{hex}@example.com", username: "pubauth#{hex}")
    pub_group.add_admin!(pub_author)
    pub_disc = DiscussionService.build(params: { title: "PubDisc", group_id: pub_group.id, private: false, description_format: "html" }, actor: pub_author)
    pub_disc.save(validate: false)
    pub_disc.create_missing_created_event!

    query = DiscussionQuery.visible_to(group_ids: [pub_group.id])
    assert_includes query, pub_disc
  end

  test "logged out shows nothing if no public groups are specified" do
    priv_group = Group.new(name: "PrivGroup #{SecureRandom.hex(4)}", is_visible_to_public: false)
    priv_group.save(validate: false)
    hex = SecureRandom.hex(4)
    priv_author = User.create!(name: "privauth#{hex}", email: "privauth#{hex}@example.com", username: "privauth#{hex}")
    priv_group.add_admin!(priv_author)
    priv_disc = DiscussionService.build(params: { title: "PrivDisc", group_id: priv_group.id, private: true, description_format: "html" }, actor: priv_author)
    priv_disc.save(validate: false)
    priv_disc.create_missing_created_event!

    query = DiscussionQuery.visible_to(group_ids: [priv_group.id])
    refute_includes query, priv_disc
  end

  # -- Unread --

  test "unread discussions with no comments" do
    results = DiscussionQuery.visible_to(user: @user, only_unread: true)
    assert_includes results, @discussion
  end

  test "does not include dismissed discussions" do
    TopicReader.for(user: @user, topic: @discussion.topic).dismiss!
    results = DiscussionQuery.visible_to(user: @user, only_unread: true)
    refute_includes results, @discussion
  end

  # -- Privacy --

  test "privacy nullgroup" do
    hex = SecureRandom.hex(4)
    disc_user = User.create!(name: "discuser#{hex}", email: "discuser#{hex}@example.com", username: "discuser#{hex}")
    group_user = User.create!(name: "groupuser#{hex}", email: "groupuser#{hex}@example.com", username: "groupuser#{hex}")
    public_user = User.create!(name: "publicuser#{hex}", email: "publicuser#{hex}@example.com", username: "publicuser#{hex}")

    parent_group = Group.new(name: "ParPriv #{hex}", discussion_privacy_options: 'public_or_private')
    parent_group.save(validate: false)
    child_group = Group.new(name: "ChildPriv #{hex}", discussion_privacy_options: 'public_or_private', parent: parent_group)
    child_group.save(validate: false)

    child_group.add_member!(group_user)
    child_group.add_admin!(@author)
    disc = DiscussionService.create(params: { title: "Null #{SecureRandom.hex(4)}", group_id: child_group.id, private: true }, actor: @author)
    disc.add_guest!(disc_user, disc.author)
    disc.topic.update!(group_id: nil)

    assert DiscussionQuery.visible_to(user: disc_user).exists?(disc.id)
    refute DiscussionQuery.visible_to(user: group_user).exists?(disc.id)
    refute DiscussionQuery.visible_to(user: public_user, or_public: true).exists?(disc.id)
    assert disc.members.exists?(disc_user.id)
    refute disc.members.exists?(group_user.id)
    refute disc.members.exists?(public_user.id)

    ActionMailer::Base.deliveries.clear
  end

  test "privacy group" do
    hex = SecureRandom.hex(4)
    disc_user = User.create!(name: "discuser#{hex}", email: "discuser#{hex}@example.com", username: "discuser#{hex}")
    group_user = User.create!(name: "groupuser#{hex}", email: "groupuser#{hex}@example.com", username: "groupuser#{hex}")
    public_user = User.create!(name: "publicuser#{hex}", email: "publicuser#{hex}@example.com", username: "publicuser#{hex}")

    parent_group = Group.new(name: "ParPriv #{hex}", discussion_privacy_options: 'public_or_private')
    parent_group.save(validate: false)
    child_group = Group.new(name: "ChildPriv #{hex}", discussion_privacy_options: 'public_or_private', parent: parent_group)
    child_group.save(validate: false)

    child_group.add_member!(group_user)
    child_group.add_admin!(@author)
    disc = DiscussionService.create(params: { title: "Grp #{SecureRandom.hex(4)}", group_id: child_group.id, private: true }, actor: @author)
    disc.add_guest!(disc_user, disc.author)

    assert DiscussionQuery.visible_to(user: disc_user).exists?(disc.id)
    assert DiscussionQuery.visible_to(user: group_user).exists?(disc.id)
    refute DiscussionQuery.visible_to(user: public_user, or_public: true).exists?(disc.id)
    assert disc.members.exists?(disc_user.id)
    assert disc.members.exists?(group_user.id)
    refute disc.members.exists?(public_user.id)

    ActionMailer::Base.deliveries.clear
  end

  test "privacy public" do
    hex = SecureRandom.hex(4)
    disc_user = User.create!(name: "discuser#{hex}", email: "discuser#{hex}@example.com", username: "discuser#{hex}")
    group_user = User.create!(name: "groupuser#{hex}", email: "groupuser#{hex}@example.com", username: "groupuser#{hex}")
    public_user = User.create!(name: "publicuser#{hex}", email: "publicuser#{hex}@example.com", username: "publicuser#{hex}")

    parent_group = Group.new(name: "ParPriv #{hex}", discussion_privacy_options: 'public_or_private', is_visible_to_public: true)
    parent_group.save(validate: false)
    child_group = Group.new(name: "ChildPriv #{hex}", discussion_privacy_options: 'public_or_private', is_visible_to_public: true, parent: parent_group)
    child_group.save(validate: false)

    child_group.add_member!(group_user)
    child_group.add_admin!(@author)
    disc = DiscussionService.create(params: { title: "Pub #{SecureRandom.hex(4)}", group_id: child_group.id, private: true }, actor: @author)
    disc.add_guest!(disc_user, disc.author)
    disc.topic.update!(private: false)

    assert DiscussionQuery.visible_to(user: disc_user).exists?(disc.id)
    assert DiscussionQuery.visible_to(user: group_user).exists?(disc.id)
    assert DiscussionQuery.visible_to(user: public_user, or_public: true).exists?(disc.id)
    assert disc.members.exists?(disc_user.id)
    assert disc.members.exists?(group_user.id)

    ActionMailer::Base.deliveries.clear
  end

  # -- Parent members can see discussions --

  test "non members cannot see discussions in subgroup with parent_members_can_see" do
    parent = Group.new(name: "ParSee #{SecureRandom.hex(4)}", group_privacy: 'secret')
    parent.save(validate: false)
    child = Group.new(
      name: "ChildSee #{SecureRandom.hex(4)}",
      parent: parent,
      parent_members_can_see_discussions: true,
      is_visible_to_public: false,
      is_visible_to_parent_members: true,
      discussion_privacy_options: 'private_only'
    )
    child.save(validate: false)
    child.add_admin!(@author)
    disc = DiscussionService.create(params: { title: "Child #{SecureRandom.hex(4)}", group_id: child.id, private: true }, actor: @author)

    results = DiscussionQuery.visible_to(user: @user, group_ids: [child.id])
    refute_includes results, disc

    ActionMailer::Base.deliveries.clear
  end

  test "member of parent group can see discussions in subgroup" do
    parent = Group.new(name: "ParSee #{SecureRandom.hex(4)}", group_privacy: 'secret')
    parent.save(validate: false)
    child = Group.new(
      name: "ChildSee #{SecureRandom.hex(4)}",
      parent: parent,
      parent_members_can_see_discussions: true,
      is_visible_to_public: false,
      is_visible_to_parent_members: true,
      discussion_privacy_options: 'private_only'
    )
    child.save(validate: false)
    child.add_admin!(@author)
    disc = DiscussionService.create(params: { title: "Child #{SecureRandom.hex(4)}", group_id: child.id, private: true }, actor: @author)

    parent.add_member!(@user)
    results = DiscussionQuery.visible_to(user: @user, group_ids: [child.id])
    assert_includes results, disc

    ActionMailer::Base.deliveries.clear
  end

  # -- Only members --

  test "prevents parent group members from seeing discussions when disabled" do
    parent = Group.new(name: "ParNoSee #{SecureRandom.hex(4)}")
    parent.save(validate: false)
    child = Group.new(
      name: "ChildNoSee #{SecureRandom.hex(4)}",
      parent: parent,
      parent_members_can_see_discussions: false,
      is_visible_to_parent_members: true
    )
    child.save(validate: false)
    child.add_admin!(@author)
    disc = DiscussionService.create(params: { title: "Child #{SecureRandom.hex(4)}", group_id: child.id, private: true }, actor: @author)

    results = DiscussionQuery.visible_to(user: @user, group_ids: [child.id])
    refute_includes results, disc

    ActionMailer::Base.deliveries.clear
  end

  # -- Archived --

  test "does not return discussions in archived groups" do
    @group.archive!
    results = DiscussionQuery.visible_to(user: @user, group_ids: [@group.id])
    refute_includes results, @discussion
  end

  # -- Guest access --

  test "guest access returns discussions via discussion reader" do
    hex = SecureRandom.hex(4)
    guest_author = User.create!(name: "guestauth#{hex}", email: "guestauth#{hex}@example.com", username: "guestauth#{hex}")
    disc = DiscussionService.build(params: { title: "Guest Disc #{hex}", private: true, description_format: "html" }, actor: guest_author)
    disc.save(validate: false)
    disc.create_missing_created_event!
    disc.add_guest!(@user, guest_author)
    assert_includes DiscussionQuery.visible_to(user: @user), disc
  end

  test "guest access does not return discussions without reader" do
    hex = SecureRandom.hex(4)
    guest_author = User.create!(name: "guestauth#{hex}", email: "guestauth#{hex}@example.com", username: "guestauth#{hex}")
    disc = DiscussionService.build(params: { title: "Guest Disc #{hex}", private: true, description_format: "html" }, actor: guest_author)
    disc.save(validate: false)
    disc.create_missing_created_event!
    refute_includes DiscussionQuery.visible_to(user: @user), disc
  end

  # -- Tags --

  test "returns tagged discussions" do
    Tag.create!(group: @group, name: 'test', color: '#abc')
    tagged = DiscussionService.create(params: { title: "Tagged #{SecureRandom.hex(4)}", group_id: @group.id, private: true, tags: ["test"] }, actor: @author)
    untagged = DiscussionService.create(params: { title: "Untagged #{SecureRandom.hex(4)}", group_id: @group.id, private: true, tags: [] }, actor: @author)

    results = DiscussionQuery.visible_to(user: @user, tags: ['test'])
    assert_includes results, tagged
    refute_includes results, untagged
  end
end
