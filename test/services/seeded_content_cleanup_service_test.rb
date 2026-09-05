require "test_helper"

class SeededContentCleanupServiceTest < ActiveSupport::TestCase
  setup do
    @member = users(:user)
    @helper_bot = User.create!(
      name: "Loomio Helper Bot",
      email: "notifications@loomio.com",
      username: "cleanup_helper_bot",
      email_verified: true,
      bot: false
    )
    @group = Group.create!(
      name: "Legacy starter group #{SecureRandom.hex(4)}",
      creator: @member,
      group_privacy: "secret"
    )
    @group.add_admin!(@helper_bot)
    @group.add_member!(@member)
  end

  test "finds fixed and group-name seeded discussions and their untouched polls" do
    fixed = create_seeded_discussion("How to use Loomio")
    dynamic = create_seeded_discussion("Welcome to #{@group.name}")
    poll = create_seeded_poll(topic_id: fixed.topic_id)

    assert_includes SeededContentCleanupService.candidate_discussions, fixed
    assert_includes SeededContentCleanupService.candidate_discussions, dynamic
    assert_includes SeededContentCleanupService.candidate_polls, poll
  end

  test "preserves member-authored content even when its title matches a seed" do
    discussion = create_seeded_discussion("Intro to Loomio", actor: @member)

    assert_not_includes SeededContentCleanupService.candidate_discussions, discussion
    SeededContentCleanupService.delete!
    assert Discussion.exists?(discussion.id)
  end

  test "preserves helper comments edited by a member or an unknown actor" do
    @group.add_admin!(@member)
    @group.update!(admins_can_edit_user_content: true)
    [ @member.id, nil ].each do |editor_id|
      discussion = create_seeded_discussion("How to use Loomio")
      poll = create_seeded_poll(topic_id: discussion.topic_id)
      comment = CommentService.create(comment: Comment.new(parent: discussion, body: "Starter text"), actor: @helper_bot)
      PaperTrail.request(whodunnit: editor_id) do
        CommentService.update(comment: comment, params: { body: "Our working instructions" }, actor: @member)
      end
      assert comment.versions.where(event: "update", whodunnit: editor_id).exists?

      SeededContentCleanupService.delete!

      assert Discussion.exists?(discussion.id)
      assert Poll.exists?(poll.id)
      assert_equal "Our working instructions", comment.reload.body
    end
  end

  test "preserves member replies even when their timeline is missing" do
    discussion = create_seeded_discussion("How to use Loomio")
    parent = CommentService.create(comment: Comment.new(parent: discussion, body: "Starter text"), actor: @helper_bot)
    reply = CommentService.create(comment: Comment.new(parent: parent, body: "Actual work"), actor: @member)
    reply.topic_items.delete_all

    SeededContentCleanupService.delete!

    assert Discussion.exists?(discussion.id)
    assert Comment.exists?(reply.id)
  end

  test "preserves a seed containing a member-authored matching-title poll" do
    discussion = create_seeded_discussion("How to use Loomio")
    poll = create_seeded_poll(topic_id: discussion.topic_id)
    poll.update_column(:author_id, @member.id)
    poll.topic_items.update_all(user_id: @helper_bot.id)

    SeededContentCleanupService.delete!

    assert Discussion.exists?(discussion.id)
    assert Poll.exists?(poll.id)
  end

  test "preserves seeded discussions with an additional member comment" do
    discussion = create_seeded_discussion("How to use Loomio")
    CommentService.create(
      comment: Comment.new(parent: discussion, body: "We used this discussion"),
      actor: @member
    )

    assert_not_includes SeededContentCleanupService.candidate_discussions, discussion
  end

  test "preserves seeded polls and their discussion after an additional member vote" do
    discussion = create_seeded_discussion("How to use Loomio")
    poll = create_seeded_poll(topic_id: discussion.topic_id)
    stance = Stance.create!(poll: poll, participant: @member)
    stance.update_column(:cast_at, Time.current)

    assert_not_includes SeededContentCleanupService.candidate_polls, poll
    assert_not_includes SeededContentCleanupService.candidate_discussions, discussion
  end

  test "allows the helper bot comment and vote that were part of seeded content" do
    discussion = create_seeded_discussion("How to use Loomio")
    poll = create_seeded_poll(topic_id: discussion.topic_id)
    CommentService.create(
      comment: Comment.new(parent: discussion, body: "Seeded helper text"),
      actor: @helper_bot
    )
    stance = Stance.create!(poll: poll, participant: @helper_bot)
    stance.update_column(:cast_at, Time.current)

    assert_includes SeededContentCleanupService.candidate_polls, poll
    assert_includes SeededContentCleanupService.candidate_discussions, discussion
  end

  test "preserves a seeded poll with a submitted anonymous ballot" do
    discussion = create_seeded_discussion("How to use Loomio")
    poll = create_seeded_poll(topic_id: discussion.topic_id, anonymous: true)
    AnonymousPollVoter.create!(
      poll: poll,
      voter: @member,
      group_member: true,
      ballot_submitted: true
    )

    assert_not_includes SeededContentCleanupService.candidate_polls, poll
    assert_not_includes SeededContentCleanupService.candidate_discussions, discussion
  end

  test "preserves seeded content with a recorded outcome or member reaction" do
    outcome_discussion = create_seeded_discussion("How to use Loomio")
    outcome_poll = create_seeded_poll(topic_id: outcome_discussion.topic_id)
    Outcome.create!(statement: "Decision recorded", poll: outcome_poll, author: @member, latest: true)
    reacted_discussion = create_seeded_discussion("Welcome! Please introduce yourself")
    Reaction.create!(reactable: reacted_discussion, user: @member, reaction: "+1")

    assert_not_includes SeededContentCleanupService.candidate_polls, outcome_poll
    assert_not_includes SeededContentCleanupService.candidate_discussions, outcome_discussion
    assert_not_includes SeededContentCleanupService.candidate_discussions, reacted_discussion
  end

  test "preserves reactions whose historical actor is unknown" do
    discussion = create_seeded_discussion("How to use Loomio")
    reaction = Reaction.create!(reactable: discussion, user: @member, reaction: "+1")
    reaction.update_column(:user_id, nil)

    SeededContentCleanupService.delete!

    assert Discussion.exists?(discussion.id)
    assert Reaction.exists?(reaction.id)
  end

  test "preserves recent, renamed, and member-edited seeded records" do
    recent = DiscussionService.create(
      params: { group_id: @group.id, title: "How to use Loomio" },
      actor: @helper_bot
    )
    renamed = create_seeded_discussion("Our project discussion")
    edited = create_seeded_discussion("How to use Loomio")
    PaperTrail::Version.create!(
      item_type: "Discussion",
      item_id: edited.id,
      event: "update",
      whodunnit: @member.id,
      object_changes: { description: [ "Seeded", "Changed" ] }
    )

    candidates = SeededContentCleanupService.candidate_discussions
    assert_not_includes candidates, recent
    assert_not_includes candidates, renamed
    assert_not_includes candidates, edited
  end

  test "deletes eligible topics and polls while retaining engaged content" do
    eligible_discussion = create_seeded_discussion("How to use Loomio")
    eligible_poll = create_seeded_poll(topic_id: eligible_discussion.topic_id)
    engaged_discussion = create_seeded_discussion("Welcome! Please introduce yourself")
    CommentService.create(
      comment: Comment.new(parent: engaged_discussion, body: "Keep this"),
      actor: @member
    )

    result = SeededContentCleanupService.delete!

    assert_equal 1, result[:discussions]
    assert_equal 1, result[:polls]
    assert_not Discussion.exists?(eligible_discussion.id)
    assert_not Poll.exists?(eligible_poll.id)
    assert Discussion.exists?(engaged_discussion.id)
  end

  test "deletes discussions and polls in separate sharded phases" do
    discussion = create_seeded_discussion("How to use Loomio")
    embedded_poll = create_seeded_poll(topic_id: discussion.topic_id)
    standalone_poll = create_seeded_poll
    shard_index = @group.id % 2

    SeededContentCleanupService.delete!(
      content_type: "discussions",
      shard_count: 2,
      shard_index: shard_index
    )

    assert_not Discussion.exists?(discussion.id)
    assert_not Poll.exists?(embedded_poll.id)
    assert Poll.exists?(standalone_poll.id)

    SeededContentCleanupService.delete!(
      content_type: "polls",
      shard_count: 2,
      shard_index: shard_index
    )

    assert_not Poll.exists?(standalone_poll.id)
  end

  private

  def create_seeded_discussion(title, actor: @helper_bot)
    DiscussionService.create(
      params: { group_id: @group.id, title: title },
      actor: actor
    ).tap do |discussion|
      discussion.update_column(:created_at, SeededContentCleanupService::CREATED_BEFORE - 1.day)
    end
  end

  def create_seeded_poll(topic_id: nil, **overrides)
    PollService.create(
      params: {
        group_id: @group.id,
        topic_id: topic_id,
        title: "Demonstration proposal",
        poll_type: "proposal",
        poll_option_names: %w[agree disagree],
        specified_voters_only: true,
        notify_on_open: false,
        closing_at: 1.week.from_now
      }.merge(overrides),
      actor: @helper_bot
    ).tap do |poll|
      poll.update_column(:created_at, SeededContentCleanupService::CREATED_BEFORE - 1.day)
    end
  end
end
