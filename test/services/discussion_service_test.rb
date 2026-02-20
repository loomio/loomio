require 'test_helper'

class DiscussionServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
    @another_user = users(:another_user)
    @group = groups(:test_group)
    # normal_user and another_user are already members via fixtures
  end

  # -- Create --

  test "creates a discussion and returns hash with discussion, topic, event" do
    result = DiscussionService.create(params: {
      title: 'Test Discussion',
      description: 'Test description',
      group_id: @group.id,
      private: true
    }, actor: @user)

    assert_kind_of Discussion, result[:discussion]
    assert_kind_of Topic, result[:topic]
    assert_kind_of Event, result[:event]
    assert result[:discussion].persisted?
    assert_equal result[:topic], result[:discussion].topic
  end

  test "does not allow unauthorized user to create discussion" do
    outsider = User.create!(name: 'Outsider', email: "outsider#{SecureRandom.hex(4)}@example.com",
                            email_verified: true, username: "outsider#{SecureRandom.hex(4)}")

    assert_raises CanCan::AccessDenied do
      DiscussionService.create(params: {
        title: 'Unauthorized Discussion',
        description: 'Test',
        group_id: @group.id,
        private: true
      }, actor: outsider)
    end
  end

  test "does not email people when creating discussion" do
    assert_no_difference 'ActionMailer::Base.deliveries.count' do
      DiscussionService.create(params: {
        title: 'Test Discussion',
        description: 'Test description',
        group_id: @group.id
      }, actor: @user)
    end
  end

  test "notifies mentioned users in discussion description" do
    @another_user.update!(username: 'mentionuser')

    assert_difference "Event.where(kind: 'user_mentioned').count", 1 do
      DiscussionService.create(params: {
        title: 'Test Discussion',
        description: "A mention for @mentionuser!",
        description_format: 'md',
        group_id: @group.id
      }, actor: @user)
    end
  end

  test "does not notify users outside the group" do
    outsider = User.create!(name: 'OutsiderMention', email: "outsiderm#{SecureRandom.hex(4)}@example.com",
                            email_verified: true, username: "outsidermention#{SecureRandom.hex(4)}")

    assert_no_difference "Event.where(kind: 'user_mentioned').count" do
      DiscussionService.create(params: {
        title: 'Test Discussion',
        description: "A mention for @#{outsider.username}!",
        description_format: 'md',
        group_id: @group.id
      }, actor: @user)
    end
  end

  test "sets volume to loud when email_on_participation is true" do
    @user.update_attribute(:email_on_participation, true)
    result = DiscussionService.create(params: {
      title: 'Loud Discussion',
      description: 'Test',
      group_id: @group.id
    }, actor: @user)
    discussion = result[:discussion]
    assert_equal 'loud', TopicReader.for(user: @user, topic: discussion.topic).volume
  end

  test "does not set volume to loud when email_on_participation is false" do
    @user.update_attribute(:email_on_participation, false)
    result = DiscussionService.create(params: {
      title: 'Normal Discussion',
      description: 'Test',
      group_id: @group.id
    }, actor: @user)
    discussion = result[:discussion]
    assert_not_equal 'loud', TopicReader.for(user: @user, topic: discussion.topic).volume
  end

  test "creates discussion reader for author" do
    result = DiscussionService.create(params: {
      title: 'Test Discussion',
      description: 'Test description',
      group_id: @group.id
    }, actor: @user)
    discussion = result[:discussion]

    reader = TopicReader.for(user: @user, topic: discussion.topic)
    assert_not_nil reader
    assert_includes ['normal', 'loud'], reader.volume
  end

  # -- Update --

  test "updates a discussion" do
    discussion = create_discussion(group: @group, author: @user)
    DiscussionService.update(discussion: discussion, actor: @user, params: { title: 'New Title' })
    assert_equal 'New Title', discussion.reload.title
  end

  test "update does not allow unauthorized user" do
    discussion = create_discussion(group: @group, author: @user)
    outsider = User.create!(name: 'Outsider', email: "outsider#{SecureRandom.hex(4)}@example.com",
                            email_verified: true, username: "outsider#{SecureRandom.hex(4)}")

    assert_raises CanCan::AccessDenied do
      DiscussionService.update(discussion: discussion, actor: outsider, params: { title: 'Hacked' })
    end
  end

  test "update allows group admin to update" do
    discussion = create_discussion(group: @group, author: @another_user)
    @group.add_admin!(@user)
    DiscussionService.update(discussion: discussion, actor: @user, params: { title: 'Admin Updated' })
    assert_equal 'Admin Updated', discussion.reload.title
  end

  # -- Discard --

  test "discard marks discussion and polls as discarded" do
    discussion = create_discussion(group: @group, author: @user)
    @group.add_admin!(@user)

    poll = Poll.new(
      title: 'Test Poll',
      poll_type: 'proposal',
      closing_at: 3.days.from_now,
      author: @user,
      topic: discussion.topic
    )
    poll.poll_options.build(name: 'agree')
    poll.poll_options.build(name: 'disagree')
    poll.save!
    poll.create_missing_created_event!

    DiscussionService.discard(discussion: discussion, actor: @user)

    assert_not_nil discussion.reload.discarded_at
    assert_not_nil poll.reload.discarded_at
  end

  # -- Move --

  test "move moves discussion to another group" do
    @group.add_admin!(@user)
    another_group = Group.create!(
      name: 'Public Group',
      handle: "publicgroup#{SecureRandom.hex(4)}",
      is_visible_to_public: true,
      discussion_privacy_options: 'public_only'
    )
    another_group.add_member!(@user)

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
      handle: "anothergroup#{SecureRandom.hex(4)}"
    )
    another_group.add_member!(@user)
    @group.add_admin!(@user)

    discussion = create_discussion(group: @group, author: @user)
    poll = Poll.new(
      title: 'Test Poll',
      poll_type: 'proposal',
      closing_at: 3.days.from_now,
      author: @user,
      topic: discussion.topic
    )
    poll.poll_options.build(name: 'agree')
    poll.poll_options.build(name: 'disagree')
    poll.save!

    DiscussionService.move(discussion: discussion, params: { group_id: another_group.id }, actor: @user)
    assert_equal another_group.id, discussion.topic.reload.group_id
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
