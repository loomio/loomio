require 'test_helper'

class TopicReaderTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @group = groups(:group)

    @discussion = discussions(:discussion)
    @membership = @admin.memberships.find_by(group: @group)
    @membership.update!(volume: :normal)
    @reader = TopicReader.for(user: @admin, topic: @discussion.topic)
  end

  # Computed volume
  test "can change its volume" do
    @reader.set_volume!(:loud)
    assert_equal :loud, @reader.reload.volume.to_sym
  end

  test "defaults to the memberships volume when nil" do
    assert_equal @membership.volume, @reader.computed_volume
  end

  # Viewed
  test "updates counts correctly from existing last_read_at" do
    @reader.update!(last_read_at: 6.days.ago)

    comment1 = Comment.new(parent: @discussion, body: "Older", author: @admin)
    older_event = CommentService.create(comment: comment1, actor: @admin)

    comment2 = Comment.new(parent: @discussion, body: "Newer", author: @admin)
    newer_event = CommentService.create(comment: comment2, actor: @admin)

    @reader.viewed!([newer_event, older_event].map(&:sequence_id))
    assert_equal 2, @reader.read_items_count
    assert @reader.last_read_at > 1.minute.ago
  end

  test "updates existing counts correctly" do
    @reader.update!(last_read_at: 6.days.ago)

    comment1 = Comment.new(parent: @discussion, body: "Older", author: @admin)
    older_event = CommentService.create(comment: comment1, actor: @admin)

    comment2 = Comment.new(parent: @discussion, body: "Newer", author: @admin)
    newer_event = CommentService.create(comment: comment2, actor: @admin)

    @reader.viewed!(newer_event.sequence_id)
    assert_not @reader.has_read?(older_event.sequence_id)
    assert @reader.has_read?(newer_event.sequence_id)
    assert_equal 1, @reader.read_items_count
  end

  test "does not duplicate views" do
    @reader.update!(last_read_at: 6.days.ago)

    comment = Comment.new(parent: @discussion, body: "Older", author: @admin)
    event = CommentService.create(comment: comment, actor: @admin)

    @reader.viewed!(event.sequence_id)
    assert_equal 1, @reader.read_items_count
    @reader.viewed!(event.sequence_id)
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
