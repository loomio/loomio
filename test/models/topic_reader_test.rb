require 'test_helper'

class TopicReaderTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @group = groups(:group)

    @discussion = discussions(:discussion)
    @membership = @admin.memberships.find_by(group: @group)
    @membership.update!(volume_email: :normal)
    @reader = TopicReader.for(user: @admin, topic: @discussion.topic)
  end

  test "guest and admin readers use user delivery defaults" do
    guest = User.create!(name: "Guest defaults", email: "guest-defaults-#{SecureRandom.hex(4)}@example.test", volume_email_default: :quiet, volume_push_default: :loud)
    admin = User.create!(name: "Admin defaults", email: "admin-defaults-#{SecureRandom.hex(4)}@example.test", volume_email_default: :loud, volume_push_default: :quiet)

    guest_reader = @discussion.topic.add_guest!(guest, @admin)
    admin_reader = @discussion.topic.add_admin!(admin, @admin)

    assert_predicate guest_reader, :email_quiet?
    assert_predicate guest_reader, :push_loud?
    assert_predicate admin_reader, :email_loud?
    assert_predicate admin_reader, :push_quiet?
  end

  test "guest invitation is not redeemable after the user joins the topic group" do
    guest = User.create!(name: "Guest becoming member", email: "guest-member-#{SecureRandom.hex(4)}@example.test")
    reader = @discussion.topic.add_guest!(guest, @admin)

    assert_includes TopicReader.redeemable, reader

    @group.add_member!(guest)

    refute_includes TopicReader.redeemable, reader
  end

  test "for leaves a missing reader unpersisted on read paths" do
    user = User.create!(name: "Lazy reader", email: "lazy-reader-#{SecureRandom.hex(4)}@example.test")

    assert_no_difference -> { TopicReader.count } do
      assert_predicate TopicReader.for(user: user, topic: @discussion.topic), :new_record?
    end
  end

  test "find_or_create_for reuses a reader without aborting its surrounding transaction" do
    user = User.create!(
      name: "Persistent reader",
      email: "persistent-reader-#{SecureRandom.hex(4)}@example.test",
      volume_email_default: :quiet,
      volume_push_default: :loud
    )
    reader = TopicReader.find_or_create_for!(user: user, topic: @discussion.topic)

    ApplicationRecord.transaction do
      existing_reader = TopicReader.find_or_create_for!(user: user, topic: @discussion.topic)

      assert_equal reader.id, existing_reader.id
      assert_equal 1, TopicReader.where(user: user, topic: @discussion.topic).count
      assert_predicate existing_reader, :email_quiet?
      assert_predicate existing_reader, :push_loud?
    end
  end

  # Computed volume
  test "unsaved direct-topic readers use independent account defaults without a group membership" do
    user = users(:reader_quiet)
    topic = topics(:direct_topic)
    reader = TopicReader.for(user: user, topic: topic)

    assert_not reader.persisted?
    assert_equal "loud", reader.computed_volume_email
    assert_equal "quiet", reader.computed_volume_push
    assert_not user.can?(:show, topic.topicable), "computing preferences must not grant topic access"
    assert_not TopicReader.exists?(user: user, topic: topic)
  end

  test "can change its volume" do
    @reader.set_volume!(email: :loud, push: :normal)
    assert_equal :loud, @reader.reload.volume_email.to_sym
  end

  test "defaults to the memberships volume when nil" do
    assert_equal @membership.volume_email, @reader.computed_volume_email
    assert_equal @membership.volume_push, @reader.computed_volume_push
  end

  # Viewed
  test "updates counts correctly from existing last_read_at" do
    @reader.update!(last_read_at: 6.days.ago)

    comment1 = Comment.new(parent: @discussion, body: "Older", author: @admin)
    older_event = nil
    CommentService.create(comment: comment1, actor: @admin) { |created_topic_item| older_event = created_topic_item }

    comment2 = Comment.new(parent: @discussion, body: "Newer", author: @admin)
    newer_event = nil
    CommentService.create(comment: comment2, actor: @admin) { |created_topic_item| newer_event = created_topic_item }

    @reader.viewed!([newer_event, older_event].map(&:sequence_id))
    assert_equal 2, @reader.read_items_count
    assert @reader.last_read_at > 1.minute.ago
  end

  test "updates existing counts correctly" do
    @reader.update!(last_read_at: 6.days.ago)

    comment1 = Comment.new(parent: @discussion, body: "Older", author: @admin)
    older_event = nil
    CommentService.create(comment: comment1, actor: @admin) { |created_topic_item| older_event = created_topic_item }

    comment2 = Comment.new(parent: @discussion, body: "Newer", author: @admin)
    newer_event = nil
    CommentService.create(comment: comment2, actor: @admin) { |created_topic_item| newer_event = created_topic_item }

    @reader.viewed!(newer_event.sequence_id)
    assert_not @reader.has_read?(older_event.sequence_id)
    assert @reader.has_read?(newer_event.sequence_id)
    assert_equal 1, @reader.read_items_count
  end

  test "does not duplicate views" do
    @reader.update!(last_read_at: 6.days.ago)

    comment = Comment.new(parent: @discussion, body: "Older", author: @admin)
    topic_item = nil
    CommentService.create(comment: comment, actor: @admin) { |created_topic_item| topic_item = created_topic_item }

    @reader.viewed!(topic_item.sequence_id)
    assert_equal 1, @reader.read_items_count
    @reader.viewed!(topic_item.sequence_id)
    assert_equal 1, @reader.read_items_count
  end

  # has_read?
  test "nothing read yet returns false" do
    @reader.read_ranges_string = ''
    assert_not @reader.has_read?([[1, 1]])
  end

  test "has been read returns true" do
    @reader.read_ranges_string = '1-1'
    assert @reader.has_read?([[1, 1]])
  end

  test "has not been read returns false" do
    @reader.read_ranges_string = '1-1'
    assert_not @reader.has_read?([[1, 2]])
  end

  test "complex has_read" do
    @reader.read_ranges_string = '1-5,7-9'
    assert @reader.has_read?([[7, 8]])
    assert_not @reader.has_read?([[1, 3], [7, 10]])
  end

  # mark_as_read
  test "accepts single sequence_ids" do
    @reader.mark_as_read 1
    assert_equal "1-1", @reader.read_ranges_string
  end

  test "accepts arrays of sequence_ids" do
    @reader.mark_as_read [1, 2, 3]
    assert_equal "1-3", @reader.read_ranges_string
  end

  test "creates a range" do
    @reader.mark_as_read [1, 1]
    assert_equal "1-1", @reader.read_ranges_string
  end

  test "extends a range" do
    @reader.mark_as_read [1, 1]
    @reader.mark_as_read [2, 2]
    assert_equal "1-2", @reader.read_ranges_string
  end

  test "extends a range further" do
    @reader.mark_as_read [1, 1]
    @reader.mark_as_read [2, 2]
    @reader.mark_as_read [3, 3]
    assert_equal "1-3", @reader.read_ranges_string
  end

  test "handles complex mark_as_read" do
    @reader.mark_as_read [[1, 1], [2, 2], [3, 3], [1, 3], [6, 8], [6, 7], [10, 10]]
    assert_equal "1-3,6-8,10-10", @reader.read_ranges_string
  end
end
