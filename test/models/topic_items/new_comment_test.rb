require 'test_helper'

class TopicItems::NewCommentTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @discussion = discussions(:discussion)
    @comment = Comment.new(parent: @discussion, body: "First", author: @user)
    CommentService.create(comment: @comment, actor: @user)
    @reply = Comment.new(body: "Reply", parent: @comment, author: @user)
    CommentService.create(comment: @reply, actor: @user)
  end

  test "creates an topic_item" do
    comment = Comment.new(parent: @discussion, body: "Another", author: @user)
    assert_difference -> { TopicItem.where(kind: 'new_comment').count }, 1 do
      TopicItems::NewComment.create!(
        itemable: comment,
        pinned: comment.should_pin
      )
    end
  end

  test "associates parent topic_item if comment is reply" do
    parent_topic_item = TopicItems::NewComment.where(itemable: @comment).last
    child_topic_item = TopicItems::NewComment.where(itemable: @reply).last
    assert_equal parent_topic_item.id, child_topic_item.parent_id
  end

  test "returns an topic_item" do
    comment = Comment.new(parent: @discussion, body: "Yet another", author: @user)
    result = TopicItems::NewComment.create!(
      itemable: comment,
      pinned: comment.should_pin
    )
    assert_kind_of TopicItems::NewComment, result
    assert_equal "new_comment", result.kind
    assert_equal comment.topic, result.topic
    assert_equal comment.author, result.user
  end
end
