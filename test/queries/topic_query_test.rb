require 'test_helper'

class TopicQueryTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @author = users(:admin)
    @group = groups(:group)
    @discussion = discussions(:discussion)
    ActionMailer::Base.deliveries.clear
  end

  # -- Logged out --

  test "logged out shows public topics" do
    pub_group = Group.new(name: "PubGroup #{SecureRandom.hex(4)}", is_visible_to_public: true, discussion_privacy_options: 'public_or_private')
    pub_group.save(validate: false)
    priv_group = Group.new(name: "PrivGroup #{SecureRandom.hex(4)}", is_visible_to_public: false)
    priv_group.save(validate: false)

    hex = SecureRandom.hex(4)
    pub_author = User.create!(name: "pubauth#{hex}", email: "pubauth#{hex}@example.com", username: "pubauth#{hex}")
    pub_group.add_admin!(pub_author)
    priv_group.add_admin!(pub_author)

    pub_disc = DiscussionService.build(params: { title: "Pub", group_id: pub_group.id, private: false, description_format: "html" }, actor: pub_author)
    pub_disc.save(validate: false)
    pub_disc.create_missing_created_event!

    priv_disc = DiscussionService.build(params: { title: "Priv", group_id: priv_group.id, private: true, description_format: "html" }, actor: pub_author)
    priv_disc.save(validate: false)
    priv_disc.create_missing_created_event!

    query = TopicQuery.visible_to
    assert_includes query, pub_disc.topic
    refute_includes query, priv_disc.topic
  end

  test "logged out shows topics in specified public groups" do
    pub_group = Group.new(name: "PubGroup #{SecureRandom.hex(4)}", is_visible_to_public: true, discussion_privacy_options: 'public_or_private')
    pub_group.save(validate: false)
    hex = SecureRandom.hex(4)
    pub_author = User.create!(name: "pubauth#{hex}", email: "pubauth#{hex}@example.com", username: "pubauth#{hex}")
    pub_group.add_admin!(pub_author)
    pub_disc = DiscussionService.build(params: { title: "PubDisc", group_id: pub_group.id, private: false, description_format: "html" }, actor: pub_author)
    pub_disc.save(validate: false)
    pub_disc.create_missing_created_event!

    query = TopicQuery.visible_to(group_ids: [pub_group.id])
    assert_includes query, pub_disc.topic
  end

  # -- Unread --

  test "unread topics includes topics with new activity" do
    results = TopicQuery.visible_to(user: @user, only_unread: true)
    assert_includes results, @discussion.topic
  end

  test "unread topics excludes fully read topics" do
    reader = TopicReader.for(user: @user, topic: @discussion.topic)
    sequence_ids = @discussion.topic.items.pluck(:sequence_id)
    reader.viewed!(sequence_ids)
    results = TopicQuery.visible_to(user: @user, only_unread: true)
    refute_includes results, @discussion.topic
  end

  test "does not include dismissed topics" do
    TopicReader.for(user: @user, topic: @discussion.topic).dismiss!
    results = TopicQuery.visible_to(user: @user, only_unread: true)
    refute_includes results, @discussion.topic
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

    assert TopicQuery.visible_to(user: disc_user).exists?(disc.topic.id)
    refute TopicQuery.visible_to(user: group_user).exists?(disc.topic.id)
    refute TopicQuery.visible_to(user: public_user, or_public: true).exists?(disc.topic.id)

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

    assert TopicQuery.visible_to(user: disc_user).exists?(disc.topic.id)
    assert TopicQuery.visible_to(user: group_user).exists?(disc.topic.id)
    refute TopicQuery.visible_to(user: public_user, or_public: true).exists?(disc.topic.id)

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

    assert TopicQuery.visible_to(user: disc_user).exists?(disc.topic.id)
    assert TopicQuery.visible_to(user: group_user).exists?(disc.topic.id)
    assert TopicQuery.visible_to(user: public_user, or_public: true).exists?(disc.topic.id)

    ActionMailer::Base.deliveries.clear
  end

  # -- Parent members can see discussions --

  test "non members cannot see topics in subgroup with parent_members_can_see" do
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

    results = TopicQuery.visible_to(user: @user, group_ids: [child.id])
    refute_includes results, disc.topic

    ActionMailer::Base.deliveries.clear
  end

  test "member of parent group can see topics in subgroup" do
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
    results = TopicQuery.visible_to(user: @user, group_ids: [child.id])
    assert_includes results, disc.topic

    ActionMailer::Base.deliveries.clear
  end

  test "prevents parent group members from seeing topics when disabled" do
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

    results = TopicQuery.visible_to(user: @user, group_ids: [child.id])
    refute_includes results, disc.topic

    ActionMailer::Base.deliveries.clear
  end

  # -- Archived --

  test "does not return topics in archived groups" do
    @group.archive!
    results = TopicQuery.visible_to(user: @user, group_ids: [@group.id])
    refute_includes results, @discussion.topic
  end

  # -- Guest access --

  test "guest access returns topics via topic reader" do
    hex = SecureRandom.hex(4)
    guest_author = User.create!(name: "guestauth#{hex}", email: "guestauth#{hex}@example.com", username: "guestauth#{hex}")
    disc = DiscussionService.build(params: { title: "Guest Disc #{hex}", private: true, description_format: "html" }, actor: guest_author)
    disc.save(validate: false)
    disc.create_missing_created_event!
    disc.add_guest!(@user, guest_author)
    assert_includes TopicQuery.visible_to(user: @user), disc.topic
  end

  test "guest access does not return topics without reader" do
    hex = SecureRandom.hex(4)
    guest_author = User.create!(name: "guestauth#{hex}", email: "guestauth#{hex}@example.com", username: "guestauth#{hex}")
    disc = DiscussionService.build(params: { title: "Guest Disc #{hex}", private: true, description_format: "html" }, actor: guest_author)
    disc.save(validate: false)
    disc.create_missing_created_event!
    refute_includes TopicQuery.visible_to(user: @user), disc.topic
  end

  # -- Tags --

  test "returns tagged topics" do
    Tag.create!(group: @group, name: 'test', color: '#abc')
    tagged = DiscussionService.create(params: { title: "Tagged #{SecureRandom.hex(4)}", group_id: @group.id, private: true, tags: ["test"] }, actor: @author)
    untagged = DiscussionService.create(params: { title: "Untagged #{SecureRandom.hex(4)}", group_id: @group.id, private: true, tags: [] }, actor: @author)

    results = TopicQuery.visible_to(user: @user, tags: ['test'])
    assert_includes results, tagged.topic
    refute_includes results, untagged.topic
  end

  # -- Standalone polls --

  test "returns standalone poll topics" do
    poll = PollService.create(params: {
      title: "Standalone #{SecureRandom.hex(4)}",
      poll_type: 'proposal',
      closing_at: 3.days.from_now,
      poll_option_names: ['agree', 'disagree'],
      group_id: @group.id
    }, actor: @author)

    results = TopicQuery.visible_to(user: @user)
    assert_includes results, poll.topic
  end
end
