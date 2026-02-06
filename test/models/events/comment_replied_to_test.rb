require 'test_helper'

class Events::CommentRepliedToTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "CRT User #{SecureRandom.hex(4)}", email: "crtuser_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    @replier = User.create!(name: "Replier #{SecureRandom.hex(4)}", email: "replier_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    @group = Group.create!(name: "CRT Group #{SecureRandom.hex(4)}", group_privacy: 'secret')
    @group.add_admin!(@user)
    @group.add_member!(@replier)
    @discussion = create_discussion(group: @group, author: @user)
    @parent = Comment.new(discussion: @discussion, body: "Parent", author: @user)
    CommentService.create(comment: @parent, actor: @user)
    @comment = Comment.new(discussion: @discussion, body: "Reply", parent: @parent, author: @replier)
    CommentService.create(comment: @comment, actor: @replier)
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
