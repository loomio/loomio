require 'test_helper'

class TopicItems::PositionTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @discussion = discussions(:discussion)
  end

  test "new_discussion topic_item is the root at position 0" do
    root = @discussion.created_topic_item
    assert_equal "new_discussion", root.kind
    assert_equal 0, root.sequence_id
    assert_equal 0, root.position
    assert_equal 0, root.depth
    assert_equal "00000", root.position_key
    assert_nil root.parent_id
    assert_equal @discussion.topic_id, root.topic_id
  end

  test "gives topic_items a position sequence" do
    comments = 6.times.map do |i|
      Comment.create!(parent: @discussion, body: "Comment #{i}", author: @user)
    end
    topic_items = comments.map do |c|
      TopicItem.create!(kind: "new_comment", topic: @discussion.topic, itemable: c)
    end

    assert_equal 1, topic_items[0].position
    assert_equal 1, topic_items[0].sequence_id
    assert_equal "00000-00001", topic_items[0].position_key

    assert_equal 2, topic_items[1].position
    assert_equal 2, topic_items[1].sequence_id
    assert_equal "00000-00002", topic_items[1].position_key

    assert_equal 3, topic_items[2].position
    assert_equal 3, topic_items[2].sequence_id
    assert_equal "00000-00003", topic_items[2].position_key

    assert_equal 4, topic_items[3].position
    assert_equal 4, topic_items[3].sequence_id
    assert_equal "00000-00004", topic_items[3].position_key

    assert_equal 5, topic_items[4].position
    assert_equal 5, topic_items[4].sequence_id
    assert_equal "00000-00005", topic_items[4].position_key

    assert_equal 6, topic_items[5].position
    assert_equal 6, topic_items[5].sequence_id
    assert_equal "00000-00006", topic_items[5].position_key
  end

  test "enforces max depth 2" do
    c1 = Comment.create!(parent: @discussion, body: "C1", author: @user)
    c2 = Comment.create!(body: "C2", parent: c1, author: @user)
    c3 = Comment.create!(body: "C3", parent: c2, author: @user)

    e1 = TopicItem.create!(kind: "new_comment", topic: @discussion.topic, itemable: c1)
    e2 = TopicItem.create!(kind: "new_comment", topic: @discussion.topic, itemable: c2)
    e3 = TopicItem.create!(kind: "new_comment", topic: @discussion.topic, itemable: c3)

    assert_equal 1, e1.depth
    assert_equal "00000-00001", e1.position_key
    assert_equal 1, e1.sequence_id

    assert_equal 2, e2.depth
    assert_equal "00000-00001-00001", e2.position_key
    assert_equal 2, e2.sequence_id

    assert_equal 2, e3.depth
    assert_equal "00000-00001-00002", e3.position_key
    assert_equal 3, e3.sequence_id
  end

  test "enforces max depth 1" do
    @discussion.topic.update!(max_depth: 1)
    c1 = Comment.create!(parent: @discussion, body: "C1", author: @user)
    c2 = Comment.create!(body: "C2", parent: c1, author: @user)
    c3 = Comment.create!(body: "C3", parent: c2, author: @user)

    e1 = TopicItem.create!(kind: "new_comment", topic: @discussion.topic, itemable: c1)
    e2 = TopicItem.create!(kind: "new_comment", topic: @discussion.topic, itemable: c2)
    e3 = TopicItem.create!(kind: "new_comment", topic: @discussion.topic, itemable: c3)

    assert_equal 1, e1.depth
    assert_equal "00000-00001", e1.position_key
    assert_equal 1, e2.depth
    assert_equal "00000-00002", e2.position_key
    assert_equal 1, e3.depth
    assert_equal "00000-00003", e3.position_key
  end

  test "enforces max depth 3" do
    @discussion.topic.update!(max_depth: 3)
    c1 = Comment.create!(parent: @discussion, body: "C1", author: @user)
    c2 = Comment.create!(body: "C2", parent: c1, author: @user)
    c3 = Comment.create!(body: "C3", parent: c2, author: @user)

    e1 = TopicItem.create!(kind: "new_comment", topic: @discussion.topic, itemable: c1)
    e2 = TopicItem.create!(kind: "new_comment", topic: @discussion.topic, itemable: c2)
    e3 = TopicItem.create!(kind: "new_comment", topic: @discussion.topic, itemable: c3)

    assert_equal 1, e1.depth
    assert_equal "00000-00001", e1.position_key
    assert_equal 2, e2.depth
    assert_equal "00000-00001-00001", e2.position_key
    assert_equal 3, e3.depth
    assert_equal "00000-00001-00001-00001", e3.position_key
  end

  test "reorders if parent changes" do
    c1 = Comment.create!(parent: @discussion, body: "C1", author: @user)
    c2 = Comment.create!(parent: @discussion, body: "C2", author: @user)
    e1 = TopicItem.create!(kind: "new_comment", topic: @discussion.topic, itemable: c1)
    e2 = TopicItem.create!(kind: "new_comment", topic: @discussion.topic, itemable: c2)
    assert_equal 1, e1.reload.position
    assert_equal 2, e2.reload.position
  end

  test "handles destroy" do
    c1 = Comment.create!(parent: @discussion, body: "C1", author: @user)
    c2 = Comment.create!(parent: @discussion, body: "C2", author: @user)
    e1 = TopicItem.create!(kind: "new_comment", topic: @discussion.topic, itemable: c1)
    e2 = TopicItem.create!(kind: "new_comment", topic: @discussion.topic, itemable: c2)
    assert_equal 1, e1.position
    assert_equal 2, e2.position
    e1.destroy
    TopicService.repair(@discussion.topic.id)
    e2.reload
    assert_equal 1, e2.position
    assert_equal 2, e2.sequence_id
  end
end
