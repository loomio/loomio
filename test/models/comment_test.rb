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

    refute stance.poll.stances.latest.cast.exists?(participant_id: @admin.id)
    direct = CommentService.create(comment: Comment.new(parent: stance, body: 'Before voting'), actor: @admin)
    assert_predicate direct, :persisted?
    nested = CommentService.create(comment: Comment.new(parent: reply, body: 'Nested before voting'), actor: @admin)
    assert_predicate nested, :persisted?
    ReindexSearchDocumentWorker.perform_now('Comment', nested.id)
    assert PgSearch::Document.exists?(searchable: nested)
  end

  test "vote replies require until-closed results to be available even outside the service" do
    stance = cast_vote_in_new_poll(hide_results: 'until_closed')
    comment = Comment.new(parent: stance, body: 'Reply before closing', author: @admin)
    assert_not comment.valid?
    assert_includes comment.errors.attribute_names, :parent
    assert_not @admin.can?(:create, comment)

    PollService.close(poll: stance.poll, actor: @admin)
    assert comment.valid?
    assert @admin.can?(:create, comment)
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

  test "only html comments with headings are pinned when posted" do
    [['html', '<h2>Section</h2>', true], ['html', '<p>Paragraph</p>', false],
     ['md', '<h2>Literal markup</h2>', false]].each do |format, body, pinned|
      comment = CommentService.create(comment: Comment.new(parent: @discussion, body: body, body_format: format), actor: @user)

      assert_predicate comment, :persisted?
      assert_equal @user, comment.reload.user
      assert_equal pinned, comment.created_topic_item.pinned
    end
  end

  test "a comment at the length limit can be posted and discarded after the limit is lowered" do
    @discussion.topic.update!(comment_length_max: 5)
    comment = CommentService.create(comment: Comment.new(parent: @discussion, body: '<p>12345</p>', body_format: 'html'), actor: @user)
    assert_predicate comment, :persisted?
    @discussion.topic.update!(comment_length_max: 4)

    CommentService.discard(comment: comment, actor: @user)

    assert_predicate comment.reload, :discarded?
    assert_equal @user.id, comment.discarded_by
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
