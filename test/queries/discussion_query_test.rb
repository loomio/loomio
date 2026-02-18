require 'test_helper'

class DiscussionQueryTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
    @author = users(:discussion_author)
    @group = groups(:test_group)
    @group.add_admin!(@author)
    @group.add_member!(@user)
    @discussion = create_discussion(group: @group, author: @author, private: true)
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

    # Create discussions without DiscussionService to bypass authorization
    pub_disc1 = Discussion.new(title: "Pub1", private: false, author: pub_author, group: pub_group1, description_format: "html")
    pub_disc1.save(validate: false)
    pub_disc1.create_missing_created_event!
    pub_disc2 = Discussion.new(title: "Pub2", private: false, author: pub_author, group: pub_group2, description_format: "html")
    pub_disc2.save(validate: false)
    pub_disc2.create_missing_created_event!
    priv_disc = Discussion.new(title: "Priv", private: true, author: pub_author, group: priv_group, description_format: "html")
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
    pub_disc = Discussion.new(title: "PubDisc", private: false, author: pub_author, group: pub_group, description_format: "html")
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
    priv_disc = Discussion.new(title: "PrivDisc", private: true, author: priv_author, group: priv_group, description_format: "html")
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
    DiscussionReader.for(discussion: @discussion, user: @user).dismiss!
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
    disc = create_discussion(group: child_group, author: @author, private: true)
    disc.add_guest!(disc_user, disc.author)
    disc.update(group_id: nil)

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
    disc = create_discussion(group: child_group, author: @author, private: true)
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
    disc = create_discussion(group: child_group, author: @author, private: true)
    disc.add_guest!(disc_user, disc.author)
    disc.update(private: false)

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
    disc = create_discussion(group: child, author: @author, private: true)

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
    disc = create_discussion(group: child, author: @author, private: true)

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
    disc = create_discussion(group: child, author: @author, private: true)

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
    disc = Discussion.new(title: "Guest Disc #{hex}", private: true, author: guest_author, description_format: "html")
    disc.save(validate: false)
    disc.create_missing_created_event!
    disc.add_guest!(@user, guest_author)
    assert_includes DiscussionQuery.visible_to(user: @user), disc
  end

  test "guest access does not return discussions without reader" do
    hex = SecureRandom.hex(4)
    guest_author = User.create!(name: "guestauth#{hex}", email: "guestauth#{hex}@example.com", username: "guestauth#{hex}")
    disc = Discussion.new(title: "Guest Disc #{hex}", private: true, author: guest_author, description_format: "html")
    disc.save(validate: false)
    disc.create_missing_created_event!
    refute_includes DiscussionQuery.visible_to(user: @user), disc
  end

  # -- Tags --

  test "returns tagged discussions" do
    Tag.create!(group: @group, name: 'test', color: '#abc')
    tagged = create_discussion(group: @group, author: @author, private: true, tags: ["test"])
    untagged = create_discussion(group: @group, author: @author, private: true, tags: [])

    results = DiscussionQuery.visible_to(user: @user, tags: ['test'])
    assert_includes results, tagged
    refute_includes results, untagged
  end
end
