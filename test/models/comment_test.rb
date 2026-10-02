require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @admin = users(:admin)
    @alien = users(:alien)
    @group = groups(:group)
    @discussion = discussions(:discussion)
  end

  test "creating vote replies does not require the author to have voted" do
    stance = cast_vote_in_new_poll(hide_results: 'until_vote')
    reply = CommentService.create(comment: Comment.new(parent: stance, body: 'Conversation after voting'), actor: @user)
    assert_predicate reply, :persisted?

    refute stance.poll.stances.latest.decided.exists?(participant_id: @admin.id)
    direct = CommentService.create(comment: Comment.new(parent: stance, body: 'Before voting'), actor: @admin)
    assert_predicate direct, :persisted?
    nested = CommentService.create(comment: Comment.new(parent: reply, body: 'Nested before voting'), actor: @admin)
    assert_predicate nested, :persisted?
    refute_includes Comment.hidden_until_closed, nested
  end

  test "until closed search and export scope includes all poll comments at maximum depth" do
    stance = cast_vote_in_new_poll(hide_results: 'off')
    reply = CommentService.create(comment: Comment.new(parent: stance, body: 'First reply'), actor: @user)
    nested = CommentService.create(comment: Comment.new(parent: reply, body: 'Second reply'), actor: @admin)
    deep = CommentService.create(comment: Comment.new(parent: nested, body: 'Third reply'), actor: @user)
    direct = CommentService.create(comment: Comment.new(parent: stance.poll, body: 'Direct poll comment'), actor: @user)
    ordinary = CommentService.create(comment: Comment.new(parent: @discussion, body: 'Ordinary discussion'), actor: @user)
    stance.poll.update!(hide_results: 'until_closed')

    [reply, nested, deep, direct].each do |comment|
      assert_includes Comment.hidden_until_closed, comment
      assert @user.can?(:show, comment)
    end
    refute_includes Comment.hidden_until_closed, ordinary
    assert Comment.new(parent: deep, body: 'Hidden nested reply', author: @user).valid?
    PollService.close(poll: stance.poll, actor: @admin)
    assert_empty Comment.hidden_until_closed
  end

  test "replies to votes are allowed when results are always visible" do
    stance = cast_vote_in_new_poll(hide_results: "off")

    assert Comment.new(parent: stance, body: "Replying to a visible vote", author: @admin).valid?
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

  private

  def cast_vote_in_new_poll(hide_results:)
    poll = PollService.create(
      params: {topic_id: @discussion.topic_id, title: "Reply check", poll_type: "proposal",
               poll_option_names: ["Agree", "Disagree"], closing_at: 3.days.from_now, hide_results: hide_results},
      actor: @admin
    )
    stance = poll.stances.latest.find_by!(participant_id: @user.id)
    stance.choice = "Agree"
    stance.reason = "My reason"
    StanceService.create(stance: stance, actor: @user)
    stance.reload
  end
end
