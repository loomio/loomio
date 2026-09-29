require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @admin = users(:admin)
    @alien = users(:alien)
    @group = groups(:group)
    @discussion = discussions(:discussion)
  end

  test "replies to votes wait until the poll's results are visible to everyone" do
    %w[until_vote until_closed].each do |hide_results|
      stance = cast_vote_in_new_poll(hide_results: hide_results)

      own_reply = Comment.new(parent: stance, body: "Replying to my own vote", author: @user)
      other_reply = Comment.new(parent: stance, body: "Replying to their vote", author: @admin)
      refute own_reply.valid?, "#{hide_results}: voter could reply to their own hidden vote"
      refute other_reply.valid?, "#{hide_results}: member could reply to a hidden vote"
      assert_includes own_reply.errors.details[:parent], {error: :invalid}

      PollService.close(poll: stance.poll, actor: @admin)
      assert Comment.new(parent: stance.reload, body: "After closing", author: @admin).valid?, "#{hide_results}: reply blocked after closing"
    end
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
