require 'test_helper'

class ThreadMarkdownServiceTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @member = users(:member)
    @group = groups(:group)
  end

  test "renders thread context and chronological comments with reply context" do
    travel_to Time.zone.parse('2026-07-15 10:00:00 UTC') do
      discussion = create_discussion
      comment = Comment.new(body: '<h1>First point</h1><p>We should proceed.</p>', body_format: 'html', parent: discussion)
      CommentService.create(comment: comment, actor: @member)

      travel 1.hour
      reply = Comment.new(body: '<p>I agree with this.</p>', body_format: 'html', parent: comment)
      CommentService.create(comment: reply, actor: @admin)

      markdown = render(discussion.topic)

      assert markdown.start_with?("# A clearer thread\n\n")
      assert_includes markdown, "- **Thread type:** Discussion"
      assert_includes markdown, "- **Group:** #{@group.name}"
      assert_includes markdown, "- **Started by:** #{@admin.name}"
      assert_includes markdown, "- **Tags:** governance, planning"
      assert_includes markdown, "## Context\n\n### Purpose"
      assert_includes markdown, "### Comment — #{@member.name}"
      assert_includes markdown, "#### First point"
      assert_includes markdown, "- **In reply to:** comment by #{@member.name}"
      assert_operator markdown.index('We should proceed.'), :<, markdown.index('I agree with this.')
      refute_includes markdown, 'New comment'
    end
  end

  test "renders poll state, visible results, vote reasons, and outcomes" do
    travel_to Time.zone.parse('2026-07-15 10:00:00 UTC') do
      discussion = create_discussion
      poll = PollService.create(
        params: {
          topic_id: discussion.topic_id,
          title: 'Adopt the plan',
          details: '<p>Decide whether to adopt the plan.</p>',
          details_format: 'html',
          poll_type: 'proposal',
          poll_option_names: ['Agree', 'Disagree'],
          closing_at: 3.days.from_now
        },
        actor: @admin
      )
      stance = poll.stances.latest.find_by!(participant_id: @member.id)
      stance.choice = 'Agree'
      stance.reason = '<p>It addresses the main concern.</p>'
      stance.reason_format = 'html'
      StanceService.create(stance: stance, actor: @member)
      PollService.close(poll: poll, actor: @admin)
      OutcomeService.create(outcome: Outcome.new(poll: poll, statement: '<p>The plan was adopted.</p>', statement_format: 'html'), actor: @admin)

      markdown = render(discussion.topic)

      assert_includes markdown, "### Poll — Adopt the plan"
      assert_includes markdown, "- **Type:** Proposal"
      assert_includes markdown, "- **Status:** Closed"
      assert_includes markdown, "- **Options:** Agree; Disagree"
      assert_includes markdown, "#### Current results"
      assert_includes markdown, "- **Agree:** 1 voter"
      assert_includes markdown, "### Vote — #{@member.name} — Adopt the plan"
      assert_includes markdown, "- **Response:** Agree"
      assert_includes markdown, "#### Reason\n\nIt addresses the main concern."
      assert_includes markdown, "### Outcome — Adopt the plan"
      assert_includes markdown, "- **Status:** Current"
      assert_includes markdown, "The plan was adopted."
    end
  end

  test "detached anonymous polls render aggregate results without individual votes" do
    discussion = create_discussion
    poll = PollService.create(
      params: {
        topic_id: discussion.topic_id,
        title: "Detached anonymous check",
        poll_type: "proposal",
        poll_option_names: ["Agree", "Disagree"],
        closing_at: 3.days.from_now,
        anonymous: true
      },
      actor: @admin
    )
    AnonymousBallotService.create(
      anonymous_ballot: poll.anonymous_ballots.build(
        anonymous_ballot_choices_attributes: [
          {poll_option_id: poll.poll_options.find_by!(name: "Agree").id}
        ]
      ),
      actor: @member
    )

    open_markdown = render(discussion.topic)
    assert_includes open_markdown, "Hidden until the poll closes"
    refute_includes open_markdown, "### Vote —"
    refute_includes open_markdown, @member.name

    PollService.close(poll: poll, actor: @admin)
    closed_markdown = render(discussion.topic)
    assert_includes closed_markdown, "- **Agree:** 1 voter"
    refute_includes closed_markdown, "### Vote —"
    refute_includes closed_markdown, @member.name
  end

  test "does not expose results or vote reasons before they are visible" do
    travel_to Time.zone.parse('2026-07-15 10:00:00 UTC') do
      discussion = create_discussion
      poll = PollService.create(
        params: {
          topic_id: discussion.topic_id,
          title: 'Hidden result check',
          poll_type: 'proposal',
          poll_option_names: ['Agree', 'Disagree'],
          closing_at: 3.days.from_now,
          hide_results: 'until_closed'
        },
        actor: @admin
      )
      stance = poll.stances.latest.find_by!(participant_id: @member.id)
      stance.choice = 'Agree'
      stance.reason = 'This reason is still private.'
      StanceService.create(stance: stance, actor: @member)

      markdown = render(discussion.topic)

      assert_includes markdown, "_Hidden until the poll closes._"
      refute_includes markdown, "1 voter"
      refute_includes markdown, "This reason is still private."
      refute_includes markdown, "### Vote —"
    end
  end

  test "renders a standalone poll as the thread overview without duplicating it in activity" do
    travel_to Time.zone.parse('2026-07-15 10:00:00 UTC') do
      poll = PollService.create(
        params: {
          group_id: @group.id,
          title: 'Standalone decision',
          details: 'Choose one option.',
          poll_type: 'proposal',
          poll_option_names: ['Agree', 'Disagree'],
          closing_at: 3.days.from_now
        },
        actor: @admin
      )

      markdown = render(poll.topic)

      assert_includes markdown, "# Standalone decision"
      assert_includes markdown, "## Poll"
      assert_includes markdown, "Choose one option."
      assert_equal 1, markdown.scan(/^## Poll$/).length
      refute_includes markdown, "### Poll — Standalone decision"
    end
  end

  private

  def create_discussion
    DiscussionService.create(
      params: {
        title: 'A clearer thread',
        description: '<h1>Purpose</h1><p>Choose the next step.</p>',
        description_format: 'html',
        group_id: @group.id,
        tags: ['planning', 'governance']
      },
      actor: @admin
    )
  end

  def render(topic)
    ThreadMarkdownService.render(topic: topic.reload, user: @admin)
  end
end
