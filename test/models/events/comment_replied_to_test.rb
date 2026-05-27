require 'test_helper'

class Events::CommentRepliedToTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @alien = users(:alien)
    @discussion = discussions(:discussion)
    @discussion.add_guest!(@alien, @user)
    @parent = Comment.new(parent: @discussion, body: "Parent", author: @user)
    CommentService.create(comment: @parent, actor: @user)
    @comment = Comment.new(body: "Reply", parent: @parent, author: @alien)
    CommentService.create(comment: @comment, actor: @alien)
  end

  test "returns an event" do
    result = Events::CommentRepliedTo.publish!(@comment)
    assert_kind_of Event, result
  end

  test "creates a comment replied to event" do
    assert_difference -> { Event.where(kind: 'comment_replied_to').count }, 1 do
      Events::CommentRepliedTo.publish!(@comment)
    end
  end

  test "emails the parent author" do
    assert_difference -> { ActionMailer::Base.deliveries.count }, 1 do
      Events::CommentRepliedTo.publish!(@comment)
    end
  end

  test "creates a notification" do
    assert_difference -> { Notification.count }, 1 do
      Events::CommentRepliedTo.publish!(@comment)
    end
  end

  test "does not notify when comment and reply author are the same" do
    @parent.update!(author: @comment.author)
    assert_no_difference -> { Notification.count } do
      Events::CommentRepliedTo.publish!(@comment)
    end
  end
end
