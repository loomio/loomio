require 'test_helper'

class DiscussionServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
    @another_user = users(:another_user)
    @group = groups(:test_group)
    @group.add_member!(@user)
    @group.add_member!(@another_user)
  end

  # -- Create --

  test "creates a discussion and returns an event" do
    discussion = Discussion.new(
      title: 'Test Discussion',
      description: 'Test description',
      group: @group,
      author: @user,
      private: true
    )

    event = DiscussionService.create(discussion: discussion, actor: @user)

    assert_kind_of Event, event
    assert discussion.persisted?
  end

  test "does not allow unauthorized user to create discussion" do
    outsider = User.create!(name: 'Outsider', email: "outsider#{SecureRandom.hex(4)}@example.com",
                            email_verified: true, username: "outsider#{SecureRandom.hex(4)}")
    discussion = Discussion.new(
      title: 'Unauthorized Discussion',
      description: 'Test',
      group: @group,
      author: @user,
      private: true
    )

    assert_raises CanCan::AccessDenied do
      DiscussionService.create(discussion: discussion, actor: outsider)
    end
  end

  test "does not email people when creating discussion" do
    discussion = Discussion.new(
      title: 'Test Discussion',
      description: 'Test description',
      group: @group,
      author: @user
    )

    assert_no_difference 'ActionMailer::Base.deliveries.count' do
      DiscussionService.create(discussion: discussion, actor: @user)
    end
  end

  test "notifies mentioned users in discussion description" do
    @another_user.update!(username: 'mentionuser')

    discussion = Discussion.new(
      title: 'Test Discussion',
      description: "A mention for @mentionuser!",
      description_format: 'md',
      group: @group,
      author: @user
    )

    assert_difference "Event.where(kind: 'user_mentioned').count", 1 do
      DiscussionService.create(discussion: discussion, actor: @user)
    end
  end

  test "does not notify users outside the group" do
    outsider = User.create!(name: 'OutsiderMention', email: "outsiderm#{SecureRandom.hex(4)}@example.com",
                            email_verified: true, username: "outsidermention#{SecureRandom.hex(4)}")
    discussion = Discussion.new(
      title: 'Test Discussion',
      description: "A mention for @#{outsider.username}!",
      description_format: 'md',
      group: @group,
      author: @user
    )

    assert_no_difference "Event.where(kind: 'user_mentioned').count" do
      DiscussionService.create(discussion: discussion, actor: @user)
    end
  end

  test "sets volume to loud when email_on_participation is true" do
    @user.update_attribute(:email_on_participation, true)
    discussion = Discussion.new(
      title: 'Loud Discussion',
      description: 'Test',
      group: @group,
      author: @user
    )
    DiscussionService.create(discussion: discussion, actor: @user)
    assert_equal 'loud', TopicReader.for(user: @user, topic: discussion.topic).volume
  end

  test "does not set volume to loud when email_on_participation is false" do
    @user.update_attribute(:email_on_participation, false)
    discussion = Discussion.new(
      title: 'Normal Discussion',
      description: 'Test',
      group: @group,
      author: @user
    )
    DiscussionService.create(discussion: discussion, actor: @user)
    assert_not_equal 'loud', TopicReader.for(user: @user, topic: discussion.topic).volume
  end

  test "creates discussion reader for author" do
    discussion = Discussion.new(
      title: 'Test Discussion',
      description: 'Test description',
      group: @group,
      author: @user
    )

    DiscussionService.create(discussion: discussion, actor: @user)

    reader = TopicReader.for(user: @user, topic: discussion.topic)
    assert_not_nil reader
    assert_includes ['normal', 'loud'], reader.volume
  end

  # -- Update --

  test "updates a discussion" do
    discussion = create_discussion(group: @group, author: @user)

    DiscussionService.update(
      discussion: discussion,
      params: { title: 'Updated Title', description: 'Updated description' },
      actor: @user
    )

    assert_equal 'Updated Title', discussion.reload.title
    assert_equal 'Updated description', discussion.description
  end

  test "does not allow unauthorized user to update discussion" do
    discussion = create_discussion(group: @group, author: @user)
    outsider = User.create!(name: 'Outsider2', email: "outsider2#{SecureRandom.hex(4)}@example.com",
                            email_verified: true, username: "outsider2#{SecureRandom.hex(4)}")
    assert_raises CanCan::AccessDenied do
      DiscussionService.update(
        discussion: discussion,
        params: { title: 'Hacked!' },
        actor: outsider
      )
    end
  end

  test "notifies new mentions on update" do
    discussion = create_discussion(group: @group, author: @user)
    @another_user.update!(username: 'updatementionuser')

    assert_difference -> { @another_user.notifications.count }, 1 do
      DiscussionService.update(
        discussion: discussion,
        params: { description: "A mention for @updatementionuser!", description_format: 'md' },
        actor: @user
      )
    end
    assert_equal 'user_mentioned', @another_user.notifications.last.kind
  end

  test "does not renotify old mentions on update" do
    discussion = create_discussion(group: @group, author: @user)
    @another_user.update!(username: 'renotifyuser')

    assert_difference -> { @another_user.notifications.count }, 1 do
      DiscussionService.update(
        discussion: discussion,
        params: { description: "A mention for @renotifyuser!", description_format: 'md' },
        actor: @user
      )
    end

    assert_no_difference -> { @another_user.notifications.count } do
      DiscussionService.update(
        discussion: discussion,
        params: { description: "Hello again @renotifyuser", description_format: 'md' },
        actor: @user
      )
    end
  end

  test "creates a version with updated title and description" do
    discussion = create_discussion(group: @group, author: @user)
    DiscussionService.update(
      discussion: discussion,
      params: { title: "new title", description: "new description" },
      actor: @user
    )
    version = discussion.versions.last
    assert_equal "new title", version.object_changes['title'][1]
    assert_equal "new description", version.object_changes['description'][1]
  end

  test "returns false for invalid update" do
    discussion = create_discussion(group: @group, author: @user)
    result = DiscussionService.update(
      discussion: discussion,
      params: { title: "" },
      actor: @user
    )
    assert_equal false, result
  end

  # -- Update reader --

  test "can save reader volume" do
    discussion = create_discussion(group: @group, author: @user)

    DiscussionService.update_reader(
      discussion: discussion,
      params: { volume: :mute },
      actor: @user
    )
    assert_equal "mute", TopicReader.for(user: @user, topic: discussion.topic).volume
  end

  test "update_reader denies access for non-members" do
    other_group = Group.create!(name: 'OtherGroup', handle: "othergroup#{SecureRandom.hex(4)}")
    other_author = User.create!(name: 'OtherAuthor', email: "otherauthor#{SecureRandom.hex(4)}@example.com",
                                email_verified: true, username: "otherauthor#{SecureRandom.hex(4)}")
    other_group.add_member!(other_author)
    other_discussion = create_discussion(group: other_group, author: other_author)

    assert_raises CanCan::AccessDenied do
      DiscussionService.update_reader(
        discussion: other_discussion,
        params: { volume: :mute },
        actor: @user
      )
    end
  end

  # -- Move --

  test "moves discussion to another group" do
    another_group = Group.create!(
      name: 'Another Group',
      handle: "anothergroup-#{SecureRandom.hex(4)}"
    )
    another_group.add_admin!(@user)

    discussion = create_discussion(group: @group, author: @user)

    DiscussionService.move(discussion: discussion, params: { group_id: another_group.id }, actor: @user)

    assert_equal another_group, discussion.reload.group
  end

  test "does not move discussion without permission" do
    another_group = Group.create!(
      name: 'Another Group',
      handle: "anothergroup2-#{SecureRandom.hex(4)}",
      is_visible_to_public: false
    )

    discussion = create_discussion(group: @group, author: @user)

    assert_raises CanCan::AccessDenied do
      DiscussionService.move(discussion: discussion, params: { group_id: another_group.id }, actor: @user)
    end
  end

  test "does not move discussion to group user is not member of" do
    another_group = Group.create!(
      name: 'Another Group',
      handle: "anothergroup3-#{SecureRandom.hex(4)}",
      is_visible_to_public: false
    )

    discussion = create_discussion(group: @group, author: @user)

    assert_raises CanCan::AccessDenied do
      DiscussionService.move(discussion: discussion, params: { group_id: another_group.id }, actor: @user)
    end
    assert_not_equal another_group.id, discussion.reload.group_id
  end

  test "does not update other attributes on move" do
    another_group = Group.create!(
      name: 'Another Group',
      handle: "anothergroup4-#{SecureRandom.hex(4)}"
    )
    another_group.add_member!(@user)

    discussion = create_discussion(group: @group, author: @user)
    original_title = discussion.title

    DiscussionService.move(discussion: discussion, params: { group_id: another_group.id, title: 'teehee!' }, actor: @user)
    assert_not_equal 'teehee!', discussion.reload.title
    assert_equal original_title, discussion.reload.title
  end

  test "move updates privacy for public_only groups" do
    another_group = Group.create!(
      name: 'Public Only',
      handle: "publiconly#{SecureRandom.hex(4)}"
    )
    another_group.add_member!(@user)
    another_group.update_column(:discussion_privacy_options, 'public_only')

    discussion = create_discussion(group: @group, author: @user, private: true)
    DiscussionService.move(discussion: discussion, params: { group_id: another_group.id }, actor: @user)
    assert_equal false, discussion.topic.reload.private
  end

  test "move updates privacy for private_only groups" do
    source_group = Group.create!(
      name: 'Public Source',
      handle: "publicsource#{SecureRandom.hex(4)}",
      is_visible_to_public: true,
      discussion_privacy_options: 'public_or_private'
    )
    source_group.add_admin!(@user)

    another_group = Group.create!(
      name: 'Private Only',
      handle: "privateonly#{SecureRandom.hex(4)}"
    )
    another_group.add_member!(@user)
    another_group.update_column(:discussion_privacy_options, 'private_only')

    discussion = create_discussion(group: source_group, author: @user, private: false)
    DiscussionService.move(discussion: discussion, params: { group_id: another_group.id }, actor: @user)
    assert_equal true, discussion.topic.reload.private
  end

  test "move updates polls group" do
    another_group = Group.create!(
      name: 'Another Group',
      handle: "anothergroup5-#{SecureRandom.hex(4)}"
    )
    another_group.add_member!(@user)

    discussion = create_discussion(group: @group, author: @user)
    poll = Poll.new(
      title: "Move Poll",
      poll_type: "proposal",
      discussion: discussion,
      group: @group,
      author: @user,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 3.days.from_now
    )
    PollService.create(poll: poll, actor: @user)

    DiscussionService.move(discussion: discussion, params: { group_id: another_group.id }, actor: @user)
    assert_equal another_group, discussion.polls.first.group
  end

  test "does not move when members_can_edit_discussions is false and user is not author" do
    @group.update!(members_can_edit_discussions: false)
    another_group = Group.create!(
      name: 'Another Group',
      handle: "anothergroup6-#{SecureRandom.hex(4)}"
    )
    another_group.add_member!(@another_user)
    @group.add_member!(@another_user)

    discussion = create_discussion(group: @group, author: @user)

    assert_raises CanCan::AccessDenied do
      DiscussionService.move(discussion: discussion, params: { group_id: another_group.id }, actor: @another_user)
    end
  end

  # -- Close / Reopen --

  test "closes a discussion" do
    discussion = create_discussion(group: @group, author: @user)

    assert_nil discussion.topic.closed_at

    DiscussionService.close(discussion: discussion, actor: @user)

    assert_not_nil discussion.topic.reload.closed_at
  end

  test "reopens a closed discussion" do
    discussion = create_discussion(group: @group, author: @user)
    discussion.topic.update!(closed_at: 1.day.ago)

    DiscussionService.reopen(discussion: discussion, actor: @user)

    assert_nil discussion.topic.reload.closed_at
  end
end
