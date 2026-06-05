require 'test_helper'

class DiscussionTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @admin = users(:admin)
    @alien = users(:alien)
    @group = groups(:group)
  end

  # Topic foreign key / cascade
  test "destroying a discussion's topic destroys the discussion (no orphaned topic_id)" do
    discussion = DiscussionService.create(params: { group_id: @group.id, title: "Test #{SecureRandom.hex(4)}" }, actor: @admin)
    topic = discussion.topic

    topic.destroy

    refute Discussion.exists?(discussion.id), "discussion should be destroyed with its topic, not orphaned"
  end

  test "destroying a group destroys its discussions" do
    discussion = DiscussionService.create(params: { group_id: @group.id, title: "Test #{SecureRandom.hex(4)}" }, actor: @admin)
    discussion_id = discussion.id

    @group.destroy

    refute Discussion.exists?(discussion_id), "group destroy should cascade to topic then discussion"
  end

  test "destroying a discussion topic also destroys its in-thread polls" do
    discussion = DiscussionService.create(params: { group_id: @group.id, title: "Test #{SecureRandom.hex(4)}" }, actor: @admin)
    poll = PollService.create(
      params: { poll_type: "poll", title: "In-thread", poll_option_names: ["agree"],
                closing_at: 5.days.from_now, topic_id: discussion.topic_id },
      actor: @admin
    )
    assert_equal discussion.topic_id, poll.topic_id

    discussion.topic.destroy

    refute Discussion.exists?(discussion.id)
    refute Poll.exists?(poll.id), "in-thread poll shares the discussion's topic and should be destroyed too"
  end

  test "database rejects a discussion referencing a non-existent topic" do
    discussion = DiscussionService.create(params: { group_id: @group.id, title: "Test #{SecureRandom.hex(4)}" }, actor: @admin)
    discussion.update_column(:topic_id, 0)
    # FK is deferrable/initially-deferred, so it fires at commit; force the
    # check now to assert it is enforced.
    assert_raises(ActiveRecord::InvalidForeignKey) do
      ActiveRecord::Base.connection.execute("SET CONSTRAINTS ALL IMMEDIATE")
    end
  end

  # Guests
  test "returns a guest who has never been a member" do
    discussion = discussions(:discussion)
    discussion.add_guest!(@alien, @admin)
    assert_includes discussion.guests, @alien
    assert_equal 1, discussion.guests.length
  end

  test "does not return a member as guest" do
    discussion = discussions(:discussion)
    @group.add_member!(@alien)
    discussion.add_guest!(@alien, @admin)
    assert_equal 0, discussion.guests.length
  end

  test "returns a guest who was previously a member" do
    discussion = discussions(:discussion)
    membership = @group.add_member!(@alien)
    MembershipService.revoke(membership: membership, actor: @admin)
    discussion.add_guest!(@alien, @admin)
    assert_includes discussion.guests, @alien
    assert_equal 1, discussion.guests.length
  end

  # Versioning
  test "creates a new version when description is edited" do
    discussion = discussions(:discussion)
    version_count = discussion.versions.count
    discussion.update_attribute(:description, "new description")
    assert_equal version_count + 1, discussion.versions.count
  end

  # Privacy validation (lives on Topic)
  test "validates private must be private when group is private only" do
    group = Group.new(discussion_privacy_options: 'private_only')
    topic = Topic.new(group: group, private: false)
    topic.valid?
    assert_includes topic.errors.full_messages, "Private must be private"
  end

  test "new discussion has correct initial values" do
    discussion = DiscussionService.create(params: { group_id: @group.id, title: "Test #{SecureRandom.hex(4)}" }, actor: @admin)
    topic = discussion.topic.reload
    assert_equal 1, topic.items_count
    assert_not_nil topic.last_activity_at
    assert_equal 0, topic.first_sequence_id
    assert_equal 0, topic.last_sequence_id
  end

  test "creating a comment increments correctly" do
    discussion = DiscussionService.create(params: { group_id: @group.id, title: "Test #{SecureRandom.hex(4)}" }, actor: @admin)
    comment = Comment.new(parent: discussion, body: "A comment")
    event = CommentService.create(comment: comment, actor: @admin)
    event.reload
    topic = discussion.topic.reload
    assert_equal 2, topic.items_count
    assert_equal event.created_at, topic.last_activity_at
    assert_equal 0, topic.first_sequence_id
    assert_equal event.sequence_id, topic.last_sequence_id
  end

  test "deleting only comment decrements correctly" do
    discussion = DiscussionService.create(params: { group_id: @group.id, title: "Test #{SecureRandom.hex(4)}" }, actor: @admin)
    comment = Comment.new(parent: discussion, body: "A comment")
    CommentService.create(comment: comment, actor: @admin)
    comment.reload
    comment.destroy
    topic = discussion.topic
    topic.update_sequence_info!
    topic.reload
    assert_equal 1, topic.items_count
    assert_equal 0, topic.last_sequence_id
    assert_equal 0, topic.first_sequence_id
  end

  test "deleting first comment of two decrements correctly" do
    discussion = DiscussionService.create(params: { group_id: @group.id, title: "Test #{SecureRandom.hex(4)}" }, actor: @admin)
    comment1 = Comment.new(parent: discussion, body: "First")
    event1 = CommentService.create(comment: comment1, actor: @admin)

    comment2 = Comment.new(parent: discussion, body: "Second")
    event2 = CommentService.create(comment: comment2, actor: @admin)

    event1.reload
    event2.reload
    comment1.reload

    comment1.destroy
    event2.reload
    topic = discussion.topic.reload
    assert_equal 2, topic.items_count
    assert_equal event2.created_at, topic.last_activity_at
    assert_equal 0, topic.first_sequence_id
    assert_equal event2.sequence_id, topic.last_sequence_id
  end

  test "deleting last comment of two decrements correctly" do
    discussion = DiscussionService.create(params: { group_id: @group.id, title: "Test #{SecureRandom.hex(4)}" }, actor: @admin)
    comment1 = Comment.new(parent: discussion, body: "First")
    event1 = CommentService.create(comment: comment1, actor: @admin)

    comment2 = Comment.new(parent: discussion, body: "Second")
    event2 = CommentService.create(comment: comment2, actor: @admin)

    event1.reload
    comment2.reload

    comment2.destroy
    topic = discussion.topic
    topic.update_sequence_info!
    topic.reload
    assert_equal 2, topic.items_count
    assert_equal event1.reload.created_at, topic.last_activity_at
    assert_equal 0, topic.first_sequence_id
    assert_equal event1.sequence_id, topic.last_sequence_id
  end

  # Mentioning
  test "stores description as mentionable text" do
    discussion = Discussion.new(description: "Hello @#{@alien.username}!", description_format: 'md', author: @admin)
    assert_equal discussion.description, discussion.send(:mentionable_text)
  end

  test "can extract mentioned usernames" do
    discussion = Discussion.new(description: "Hello @#{@alien.username}!", description_format: 'md', author: @admin)
    assert_includes discussion.mentioned_usernames, @alien.username
  end

  test "does not duplicate usernames" do
    discussion = Discussion.new(description: "Hello @#{@alien.username}! Goodbye @#{@alien.username}!", description_format: 'md', author: @admin)
    assert_equal [@alien.username], discussion.mentioned_usernames
  end

  test "does not extract the authors username" do
    discussion = Discussion.new(description: "Hello @#{@admin.username}!", description_format: 'md', author: @admin)
    assert_not_includes discussion.mentioned_usernames, @admin.username
  end
end
