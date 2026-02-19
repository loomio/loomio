require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  setup do
    @user = users(:discussion_author)
    @group = groups(:test_group)
    @discussion = discussions(:test_discussion)
  end

  test "removes script tags from html body" do
    comment = Comment.new(parent: @discussion, author: @user, body_format: "html")
    comment.body = "hi im a hacker <script>alert('hacked')</script>"
    comment.save!
    assert_equal "hi im a hacker alert('hacked')", comment.body
  end

  test "is_most_recent when comment is the last one" do
    comment = Comment.new(parent: @discussion, body: "First comment", author: @user)
    CommentService.create(comment: comment, actor: @user)
    assert comment.is_most_recent?
  end

  test "is not most_recent when a newer comment exists" do
    comment = Comment.new(parent: @discussion, body: "First comment", author: @user)
    CommentService.create(comment: comment, actor: @user)

    newer = Comment.new(parent: @discussion, body: "Second comment", author: @user)
    CommentService.create(comment: newer, actor: @user)

    assert_not comment.is_most_recent?
  end

  test "destroy removes reactions" do
    comment = Comment.new(parent: @discussion, body: "Reacted comment", author: @user)
    CommentService.create(comment: comment, actor: @user)

    reaction = Reaction.new(reactable: comment)
    ReactionService.update(reaction: reaction, params: { reaction: 'smiley' }, actor: @user)
    assert Reaction.where(reactable: comment, user_id: @user.id).exists?

    comment.destroy
    assert_not Reaction.where(reactable: comment, user_id: @user.id).exists?
  end

  test "mentioned_users returns group member mentioned by username" do
    member = User.create!(name: "Member #{SecureRandom.hex(4)}", email: "member_#{SecureRandom.hex(4)}@test.com")
    @group.add_member!(member)

    comment = Comment.new(parent: @discussion, body: "@#{member.username}", author: @user)
    CommentService.create(comment: comment, actor: @user)

    assert_includes comment.mentioned_users, member
  end

  test "mentioned_users does not return member of another group" do
    another_group = Group.create!(name: "Other Group #{SecureRandom.hex(4)}", group_privacy: 'secret')
    another_member = User.create!(name: "Other #{SecureRandom.hex(4)}", email: "other_#{SecureRandom.hex(4)}@test.com")
    another_group.add_member!(another_member)
    another_group.add_member!(@user)

    comment = Comment.new(parent: @discussion, body: "@#{another_member.username}", author: @user)
    CommentService.create(comment: comment, actor: @user)

    assert_not_includes comment.mentioned_users, another_member
  end

  test "mentioned_users does not return non-members" do
    non_member = User.create!(name: "NonMember #{SecureRandom.hex(4)}", email: "nonmember_#{SecureRandom.hex(4)}@test.com")

    comment = Comment.new(parent: @discussion, body: "@#{non_member.username}", author: @user)
    CommentService.create(comment: comment, actor: @user)

    assert_not_includes comment.mentioned_users, non_member
  end
end
