require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @admin = users(:admin)
    @alien = users(:alien)
    @group = groups(:group)
    @discussion = discussions(:discussion)
  end

  test "removes script tags from html body" do
    comment = Comment.new(parent: @discussion, author: @user, body_format: "html")
    comment.body = "hi im a hacker <script>alert('hacked')</script>"
    comment.save!
    assert_equal "hi im a hacker alert('hacked')", comment.body
  end

  test "mentioned_users returns group member mentioned by username" do
    comment = Comment.new(parent: @discussion, body: "@#{@user.username}")
    CommentService.create(comment: comment, actor: @admin)
    assert_includes comment.mentioned_users, @user
  end

  test "mentioned_users does not return non members" do
    comment = Comment.new(parent: @discussion, body: "@#{@alien.username}", author: @user)
    CommentService.create(comment: comment, actor: @user)

    assert_not_includes comment.mentioned_users, @alien
  end
end
