require 'test_helper'

class DiscussionTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Disc User #{SecureRandom.hex(4)}", email: "disc_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    @group = Group.create!(name: "Disc Group #{SecureRandom.hex(4)}", group_privacy: 'secret')
    @group.add_admin!(@user)
  end

  # Guests
  test "returns a guest who has never been a member" do
    discussion = create_discussion(group: @group, author: @user)
    guest = User.create!(name: "Guest #{SecureRandom.hex(4)}", email: "guest_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    discussion.add_guest!(guest, @user)
    assert_includes discussion.guests, guest
    assert_equal 1, discussion.guests.length
  end

  test "does not return a member as guest" do
    discussion = create_discussion(group: @group, author: @user)
    guest = User.create!(name: "Guest #{SecureRandom.hex(4)}", email: "guest_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    @group.add_member!(guest)
    discussion.add_guest!(guest, @user)
    assert_equal 0, discussion.guests.length
  end

  test "returns a guest who was previously a member" do
    discussion = create_discussion(group: @group, author: @user)
    guest = User.create!(name: "Guest #{SecureRandom.hex(4)}", email: "guest_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    membership = @group.add_member!(guest)
    MembershipService.revoke(membership: membership, actor: @user)
    discussion.add_guest!(guest, @user)
    assert_includes discussion.guests, guest
    assert_equal 1, discussion.guests.length
  end

  # Versioning
  test "creates a new version when description is edited" do
    PaperTrail.enabled = true
    discussion = create_discussion(group: @group, author: @user)
    version_count = discussion.versions.count
    discussion.update_attribute(:description, "new description")
    assert_equal version_count + 1, discussion.versions.count
  ensure
    PaperTrail.enabled = false
  end

  # Privacy validation
  test "validates private must be private when group is private only" do
    group = Group.new(discussion_privacy_options: 'private_only')
    discussion = Discussion.new(group: group, private: false)
    discussion.valid?
    assert_includes discussion.errors.to_a, "Private must be private"
  end

  # Thread items
  test "new discussion has correct initial values" do
    discussion = create_discussion(group: @group, author: @user)
    assert_equal 0, discussion.items_count
    assert_equal discussion.created_at, discussion.last_activity_at
    assert_equal 0, discussion.first_sequence_id
    assert_equal 0, discussion.last_sequence_id
  end

  test "creating a comment increments correctly" do
    discussion = create_discussion(group: @group, author: @user)
    comment = Comment.new(discussion: discussion, body: "A comment", author: @user)
    event = CommentService.create(comment: comment, actor: @user)
    event.reload
    comment.reload
    discussion.reload
    assert_equal 1, discussion.items_count
    assert_equal event.eventable.created_at, discussion.last_activity_at
    assert_equal event.sequence_id, discussion.first_sequence_id
    assert_equal event.sequence_id, discussion.last_sequence_id
  end

  test "deleting only comment decrements correctly" do
    discussion = create_discussion(group: @group, author: @user)
    comment = Comment.new(discussion: discussion, body: "A comment", author: @user)
    event = CommentService.create(comment: comment, actor: @user)
    event.reload
    discussion.reload
    comment.reload
    comment.destroy
    discussion.update_sequence_info!
    discussion.reload
    assert_equal 0, discussion.items_count
    assert_equal discussion.created_at, discussion.last_activity_at
    assert_equal 0, discussion.last_sequence_id
    assert_equal 0, discussion.first_sequence_id
  end

  test "deleting first comment of two decrements correctly" do
    discussion = create_discussion(group: @group, author: @user)
    comment1 = Comment.new(discussion: discussion, body: "First", author: @user)
    event1 = CommentService.create(comment: comment1, actor: @user)

    comment2 = Comment.new(discussion: discussion, body: "Second", author: @user)
    event2 = CommentService.create(comment: comment2, actor: @user)

    event1.reload
    event2.reload
    discussion.reload
    comment1.reload
    comment2.reload

    comment1.destroy
    discussion.reload
    assert_equal 1, discussion.items_count
    assert_equal event2.eventable.created_at, discussion.last_activity_at
    assert_equal event2.sequence_id, discussion.first_sequence_id
    assert_equal event2.sequence_id, discussion.last_sequence_id
  end

  test "deleting last comment of two decrements correctly" do
    discussion = create_discussion(group: @group, author: @user)
    comment1 = Comment.new(discussion: discussion, body: "First", author: @user)
    event1 = CommentService.create(comment: comment1, actor: @user)

    comment2 = Comment.new(discussion: discussion, body: "Second", author: @user)
    event2 = CommentService.create(comment: comment2, actor: @user)

    event1.reload
    event2.reload
    discussion.reload
    comment1.reload
    comment2.reload

    comment2.destroy
    discussion.update_sequence_info!
    discussion.reload
    assert_equal 1, discussion.items_count
    assert_equal event1.eventable.created_at, discussion.last_activity_at
    assert_equal event1.sequence_id, discussion.first_sequence_id
    assert_equal event1.sequence_id, discussion.last_sequence_id
  end

  # Mentioning
  test "stores description as mentionable text" do
    discussion = Discussion.new(description: "Hello @#{@user.username}!", description_format: 'md', author: @user)
    assert_equal discussion.description, discussion.send(:mentionable_text)
  end

  test "can extract mentioned usernames" do
    discussion = Discussion.new(description: "Hello @#{@user.username}!", description_format: 'md', author: User.new)
    assert_includes discussion.mentioned_usernames, @user.username
  end

  test "does not duplicate usernames" do
    discussion = Discussion.new(description: "Hello @#{@user.username}! Goodbye @#{@user.username}!", description_format: 'md', author: User.new)
    assert_equal [@user.username], discussion.mentioned_usernames
  end

  test "does not extract the authors username" do
    discussion = Discussion.new(description: "Hello @#{@user.username}!", description_format: 'md', author: @user)
    assert_not_includes discussion.mentioned_usernames, @user.username
  end
end
