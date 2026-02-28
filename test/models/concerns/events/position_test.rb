require 'test_helper'

class Events::PositionTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @discussion = discussions(:discussion)
  end

  test "gives events a position sequence" do
    comments = 6.times.map do |i|
      Comment.create!(parent: @discussion, body: "Comment #{i}", author: @user)
    end
    events = comments.map do |c|
      Event.create!(kind: "new_comment", topic: @discussion.topic, eventable: c)
    end

    assert_equal 1, events[0].position
    assert_equal 1, events[0].sequence_id
    assert_equal "00000-00001", events[0].position_key

    assert_equal 2, events[1].position
    assert_equal 2, events[1].sequence_id
    assert_equal "00000-00002", events[1].position_key

    assert_equal 3, events[2].position
    assert_equal 3, events[2].sequence_id
    assert_equal "00000-00003", events[2].position_key

    assert_equal 4, events[3].position
    assert_equal 4, events[3].sequence_id
    assert_equal "00000-00004", events[3].position_key

    assert_equal 5, events[4].position
    assert_equal 5, events[4].sequence_id
    assert_equal "00000-00005", events[4].position_key

    assert_equal 6, events[5].position
    assert_equal 6, events[5].sequence_id
    assert_equal "00000-00006", events[5].position_key
  end

  test "enforces max depth 2" do
    c1 = Comment.create!(parent: @discussion, body: "C1", author: @user)
    c2 = Comment.create!(body: "C2", parent: c1, author: @user)
    c3 = Comment.create!(body: "C3", parent: c2, author: @user)

    e1 = Event.create!(kind: "new_comment", topic: @discussion.topic, eventable: c1)
    e2 = Event.create!(kind: "new_comment", topic: @discussion.topic, eventable: c2)
    e3 = Event.create!(kind: "new_comment", topic: @discussion.topic, eventable: c3)

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

    e1 = Event.create!(kind: "new_comment", topic: @discussion.topic, eventable: c1)
    e2 = Event.create!(kind: "new_comment", topic: @discussion.topic, eventable: c2)
    e3 = Event.create!(kind: "new_comment", topic: @discussion.topic, eventable: c3)

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

    e1 = Event.create!(kind: "new_comment", topic: @discussion.topic, eventable: c1)
    e2 = Event.create!(kind: "new_comment", topic: @discussion.topic, eventable: c2)
    e3 = Event.create!(kind: "new_comment", topic: @discussion.topic, eventable: c3)

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
    e1 = Event.create!(kind: "new_comment", topic: @discussion.topic, eventable: c1)
    e2 = Event.create!(kind: "new_comment", topic: @discussion.topic, eventable: c2)
    assert_equal 1, e1.reload.position
    assert_equal 2, e2.reload.position
  end

  test "removes position if topic_id is dropped" do
    c1 = Comment.create!(parent: @discussion, body: "C1", author: @user)
    c2 = Comment.create!(parent: @discussion, body: "C2", author: @user)
    c3 = Comment.create!(parent: @discussion, body: "C3", author: @user)
    e1 = Event.create!(kind: "new_comment", topic: @discussion.topic, eventable: c1)
    e2 = Event.create!(kind: "new_comment", topic: @discussion.topic, eventable: c2)
    e3 = Event.create!(kind: "new_comment", topic: @discussion.topic, eventable: c3)

    assert_equal 1, e1.position
    assert_equal 2, e2.position
    assert_equal 3, e3.position

    e2.update!(topic_id: nil, parent_id: nil)
    TopicService.repair_thread(@discussion.topic.id)
    assert_equal 2, e3.reload.position
    assert_equal "00000-00002", e3.reload.position_key
    assert_equal 3, e3.reload.sequence_id
  end

  test "handles destroy" do
    c1 = Comment.create!(parent: @discussion, body: "C1", author: @user)
    c2 = Comment.create!(parent: @discussion, body: "C2", author: @user)
    e1 = Event.create!(kind: "new_comment", topic: @discussion.topic, eventable: c1)
    e2 = Event.create!(kind: "new_comment", topic: @discussion.topic, eventable: c2)
    assert_equal 1, e1.position
    assert_equal 2, e2.position
    e1.destroy
    TopicService.repair_thread(@discussion.topic.id)
    e2.reload
    assert_equal 1, e2.position
    assert_equal 2, e2.sequence_id
  end
end
