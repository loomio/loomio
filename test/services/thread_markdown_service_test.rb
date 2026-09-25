require 'test_helper'

class ThreadMarkdownServiceTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @member = users(:member)
    @group = groups(:group)
  end

  test "groups a poll's votes and replies directly beneath its results" do
    travel_to Time.zone.parse('2026-07-15 10:00:00 UTC') do
      discussion = create_discussion
      poll = create_poll(discussion, details: "<p>Decide whether to adopt the plan.</p>", details_format: "html")
      stance = cast_vote(poll, reason: "<p>It addresses the main concern.</p>")
      # An unrelated thread comment posted before the poll's own reply. It must not
      # interleave with the poll's votes and replies, which stay grouped beneath
      # the poll.
      CommentService.create(
        comment: Comment.new(body: "<p>Unrelated interjection.</p>", body_format: "html", parent: discussion),
        actor: @member
      )
      reply = Comment.new(body: "<p>I support this.</p>", body_format: "html", parent: stance)
      CommentService.create(comment: reply, actor: @admin)
      nested = Comment.new(body: "<p>Me too.</p>", body_format: "html", parent: reply)
      CommentService.create(comment: nested, actor: @member)
      deep = Comment.new(body: "<p>Way deeper.</p>", body_format: "html", parent: nested)
      CommentService.create(comment: deep, actor: @admin)

      markdown = render(discussion.topic)

      # The poll's reply renders before the unrelated later comment because it is
      # grouped with the poll, rather than scattered in chronological order.
      reply_index = markdown.index("I support this.")
      unrelated_index = markdown.index("Unrelated interjection.")
      assert_operator reply_index, :<, unrelated_index
      # The poll's votes and replies sit under a "Comments" heading right after
      # the results, each prefixed with the author's name, vote and time.
      assert_operator markdown.index("### Current results"), :<, markdown.index("### Comments")
      assert_includes markdown, "**#{@member.name}** [Agree] (2026-07-15 10:00): It addresses the main concern."
      # A reply to a vote is nested under it, marked with ↳.
      assert_includes markdown, "&nbsp;&nbsp;&nbsp;&nbsp; ↳ **#{@admin.name}** (2026-07-15 10:00): I support this."
      # A reply to that comment nests one level deeper.
      assert_includes markdown, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ↳ **#{@member.name}** [Agree] (2026-07-15 10:00): Me too."
      # A third-level reply is capped at the two nested levels, no deeper indent.
      assert_includes markdown, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ↳ **#{@admin.name}** (2026-07-15 10:00): Way deeper."
      refute_includes markdown, "&nbsp;&nbsp;&nbsp;&nbsp;" * 3
      # The nested reply renders after the comment it replies to.
      assert_operator markdown.index("I support this."), :<, markdown.index("Me too.")
      assert_equal 1, markdown.scan("It addresses the main concern.").length
      assert_equal 1, markdown.scan("I support this.").length
      assert_equal 1, markdown.scan("Me too.").length
      assert_equal 1, markdown.scan("Way deeper.").length
    end
  end

  test "poll comments keep multi-block content valid Markdown" do
    discussion = create_discussion
    poll = create_poll(discussion)
    stance = cast_vote(poll, reason: "See below.\n\n```\nx = 1\n```", reason_format: "md")
    reply = Comment.new(body: "<p>First paragraph.</p><p>Second paragraph.</p>", body_format: "html", parent: stance)
    CommentService.create(comment: reply, actor: @admin)
    Reaction.create!(reactable: reply, user: @member, reaction: "👍")

    markdown = render(discussion.topic)

    # The author line stands alone, so the vote's closing fence stays a fence.
    assert_match(/^\*\*#{@member.name}\*\* \[Agree\] \([^)]+\):\n\nSee below\.\n\n```\nx = 1\n```\n\n&nbsp;/, markdown)
    # A multi-paragraph reply is quoted so every paragraph stays nested.
    assert_match(/↳ \*\*#{@admin.name}\*\* \([^)]+\):\n\n> First paragraph\.\n>\n> Second paragraph\.\n>\n> Reactions: 1 👍 \(#{@member.name}\)/, markdown)
  end

  test "replies to votes without a reason stay with the poll and name the voter" do
    # A vote without a reason has no thread item, so its reply has no parent
    # entry to nest under.
    discussion = create_discussion
    poll = create_poll(discussion)
    stance = cast_vote(poll, reason: nil)
    CommentService.create(comment: Comment.new(body: "<p>Why this choice?</p>", body_format: "html", parent: stance), actor: @admin)
    CommentService.create(comment: Comment.new(body: "<p>Later thread comment.</p>", body_format: "html", parent: discussion), actor: @member)

    markdown = render(discussion.topic)

    assert_match(/^### Comments\n\n\*\*#{@admin.name}\*\* \([^)]+, in reply to #{@member.name}\): Why this choice\?$/, markdown)
    assert_operator markdown.index("Why this choice?"), :<, markdown.index("Later thread comment.")
  end

  test "replies to hidden votes say what they reply to without naming the voter" do
    discussion = create_discussion
    poll = create_poll(discussion, hide_results: "until_closed")
    stance = cast_vote(poll, reason: "<p>Private reasoning.</p>")
    CommentService.create(comment: Comment.new(body: "<p>Replying to that vote.</p>", body_format: "html", parent: stance), actor: @admin)
    deleted = Comment.new(body: "<p>Removed later.</p>", body_format: "html", parent: poll)
    CommentService.create(comment: deleted, actor: @member)
    CommentService.create(comment: Comment.new(body: "<p>Answering the removed comment.</p>", body_format: "html", parent: deleted), actor: @admin)
    deleted.discard!

    markdown = render(discussion.topic)

    refute_includes markdown, "Private reasoning."
    refute_includes markdown, "Removed later."
    assert_match(/^\*\*#{@admin.name}\*\* \([^)]+, in reply to a hidden vote\): Replying to that vote\.$/, markdown)
    assert_match(/^\*\*#{@admin.name}\*\* \([^)]+, in reply to #{@member.name}\): Answering the removed comment\.$/, markdown)
  end

  test "poll comments show the start of each author's visible vote" do
    discussion = create_discussion
    poll = create_poll(discussion, poll_option_names: ["Agree with the whole proposal", "Disagree"])
    stance = cast_vote(poll, reason: "<p>Mostly convinced.</p>", choice: "Agree with the whole proposal")
    reply = Comment.new(body: "<p>Why not fully?</p>", body_format: "html", parent: stance)
    CommentService.create(comment: reply, actor: @admin)
    CommentService.create(comment: Comment.new(body: "<p>Some doubts remain.</p>", body_format: "html", parent: reply), actor: @member)

    markdown = render(discussion.topic)

    assert_match(/^\*\*#{@member.name}\*\* \[Agree with the whol…\] \([^)]+\): Mostly convinced\.$/, markdown)
    # The admin has not voted, so their reply carries no vote.
    assert_match(/↳ \*\*#{@admin.name}\*\* \([^)]+\): Why not fully\?$/, markdown)
    # A reply by a voter carries the voter's current vote too.
    assert_match(/↳ \*\*#{@member.name}\*\* \[Agree with the whol…\] \([^)]+\): Some doubts remain\.$/, markdown)
  end

  test "poll comments do not show votes the reader cannot see" do
    discussion = create_discussion
    poll = create_poll(discussion, hide_results: "until_closed")
    cast_vote(poll, reason: nil)
    CommentService.create(comment: Comment.new(body: "<p>My view on the poll.</p>", body_format: "html", parent: poll), actor: @member)

    assert_match(/^\*\*#{@member.name}\*\* \([^)]+\): My view on the poll\.$/, render(discussion.topic))
    assert_match(/^\*\*#{@member.name}\*\* \[Agree\] \([^)]+\): My view on the poll\.$/, render(discussion.topic, user: @member))
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

      assert markdown.start_with?("---\ngroup: \"#{@group.name}\"\ncreated: \"")
      assert_includes markdown, "tags: [\"governance\",\"planning\"]"
      assert_match(/^# Discussion: A clearer thread · #{@admin.name} 2026-07-15 10:00$/, markdown)
      refute_includes markdown, "**Thread type:**"
      refute_includes markdown, "**Group:**"
      refute_includes markdown, "## Context"
      refute_includes markdown, "## Activity"
      assert_includes markdown, "## Purpose"
      assert_includes markdown, "## Comment · #{@member.name} 2026-07-15 10:00"
      assert_includes markdown, "### First point"
      assert_includes markdown, "## Reply to #{@member.name} · #{@admin.name} 2026-07-15 11:00"
      refute_includes markdown, "**In reply to:**"
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

      assert_includes markdown, "## Proposal: Adopt the plan · #{@admin.name} 2026-07-15 10:00"
      assert_equal 1, markdown.scan(/^## Proposal: Adopt the plan/).length
      refute_includes markdown, "**Type:**"
      assert_includes markdown, "- **Status:** Closed"
      assert_includes markdown, "- **Options:** Agree; Disagree"
      assert_includes markdown, "### Current results"
      assert_match(/\| Agree\s+\| 1\s+\| 100%\s+\| 10%\s+\| #{@member.name}\s+\|/, markdown)
      assert_match(/\| Undecided\s+\| 9\s+\|\s+\| 90%\s+\| .*#{@admin.name}.*\|/, markdown)
      assert_includes markdown, "### Comments"
      assert_includes markdown, "**#{@member.name}** [Agree] (2026-07-15 10:00): It addresses the main concern."
      refute_includes markdown, "## Vote:"
      refute_includes markdown, "\n- Agree\n"
      assert_operator markdown.index("### Current results"), :<, markdown.index("It addresses the main concern.")
      refute_includes markdown, "**Response:**"
      refute_includes markdown, "### Reason"
      assert_includes markdown, "## Outcome · #{@admin.name} 2026-07-15 10:00"
      refute_includes markdown, "## Outcome · Adopt the plan"
      refute_includes markdown, "- **Status:** Current"
      assert_match(/^## Outcome · #{@admin.name} \d{4}-\d{2}-\d{2} \d{2}:\d{2}\n\nThe plan was adopted\.$/, markdown)
      refute_match(/^## Outcome.*\n{3,}/, markdown)
    end
  end

  test "renders voters by option and named reactions" do
    discussion = create_discussion
    comment = Comment.new(body: "Please record the support.", parent: discussion)
    CommentService.create(comment: comment, actor: @admin)
    Reaction.create!(reactable: comment, user: @member, reaction: "👍")
    Reaction.create!(reactable: comment, user: @admin, reaction: "👍")
    poll = PollService.create(
      params: {
        topic_id: discussion.topic_id,
        title: "Adopt the plan",
        poll_type: "proposal",
        poll_option_names: ["Agree", "Disagree"],
        closing_at: 3.days.from_now
      },
      actor: @admin
    )
    stance = poll.stances.latest.find_by!(participant_id: @member.id)
    stance.choice = "Agree"
    stance.reason = "This option has my support."
    StanceService.create(stance: stance, actor: @member)
    Reaction.create!(reactable: stance, user: @admin, reaction: "❤️")
    CommentService.create(
      comment: Comment.new(body: "Can we confirm the participants?", parent: stance),
      actor: @admin
    )

    markdown = render(discussion.topic)

    assert_includes markdown, "| Option | Votes | % of votes cast | % of eligible voters | Voters |"
    assert_match(/\| Agree\s+\| 1\s+\| 100%\s+\| 10%\s+\| #{@member.name}\s+\|/, markdown)
    assert_match(/\| Disagree\s+\| 0\s+\| 0%\s+\| 0%\s+\| No voters\s+\|/, markdown)
    refute_includes markdown, "#### Reactions"
    assert_includes markdown, "- 👍 #{@member.name}, #{@admin.name}"
    assert_includes markdown, "1 ❤️ (#{@admin.name})"
    assert_match(/^&nbsp;&nbsp;&nbsp;&nbsp; ↳ \*\*#{@admin.name}\*\* \(\d{4}-\d{2}-\d{2} \d{2}:\d{2}\): Can we confirm the participants\?$/, markdown)
    refute_includes markdown, "**In reply to:**"
    assert_includes markdown, "Can we confirm the participants?"
  end

  test "formats multiple scored vote choices for the heading" do
    poll = OpenStruct.new(has_variable_score: true)
    choices = [
      OpenStruct.new(poll_option: OpenStruct.new(name: "apples", priority: 0), score: 2),
      OpenStruct.new(poll_option: OpenStruct.new(name: "bananas", priority: 1), score: 3)
    ]
    stance = OpenStruct.new(none_of_the_above?: false, poll: poll, stance_choices: choices)
    service = ThreadMarkdownService.new(topics(:discussion_topic), @admin)

    assert_equal "apples 2, bananas 3", service.send(:stance_response_heading, stance)
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
    assert_includes open_markdown, "- **Anonymous voting:** Yes"
    assert_includes open_markdown, "Hidden until the poll closes"
    refute_includes open_markdown, "## Vote"
    refute_includes open_markdown, @member.name

    PollService.close(poll: poll, actor: @admin)
    closed_markdown = render(discussion.topic)
    assert_match(/\| Agree\s+\| 1\s+\| 100%\s+\| 10%\s+\| Anonymous\s+\|/, closed_markdown)
    assert_match(/\| Undecided\s+\| 9\s+\|\s+\| 90%\s+\| Anonymous\s+\|/, closed_markdown)
    assert_equal 1, closed_markdown.scan(/^## Proposal: Detached anonymous check/).length
    refute_includes closed_markdown, "## Vote"
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
      refute_includes markdown, "| Option | Result | Voters |"
      refute_includes markdown, "1 voter"
      refute_includes markdown, "This reason is still private."
      refute_includes markdown, "## Vote"
    end
  end

  test "until vote rendering is hidden from non-voters and visible to voters" do
    discussion = create_discussion
    poll = PollService.create(
      params: {
        topic_id: discussion.topic_id,
        title: 'Vote before viewing',
        poll_type: 'proposal',
        poll_option_names: ['Agree', 'Disagree'],
        closing_at: 3.days.from_now,
        hide_results: 'until_vote'
      },
      actor: @admin
    )
    stance = poll.stances.latest.find_by!(participant_id: @member.id)
    stance.choice = 'Agree'
    stance.reason = 'Visible after voting.'
    StanceService.create(stance: stance, actor: @member)

    hidden_markdown = render(discussion.topic, user: @admin)
    visible_markdown = render(discussion.topic, user: @member)

    assert_includes hidden_markdown, '_Hidden until the viewer votes._'
    refute_includes hidden_markdown, 'Visible after voting.'
    assert_includes visible_markdown, 'Visible after voting.'
  end

  test "renders document labels in the viewer locale" do
    I18n.backend.store_translations(:es, thread_markdown: {
      current_results: "Resultados actuales",
      voters: "Votantes"
    })
    @admin.update!(selected_locale: "es")
    discussion = create_discussion
    PollService.create(
      params: {
        topic_id: discussion.topic_id,
        title: "Adopt the plan",
        poll_type: "proposal",
        poll_option_names: ["Agree", "Disagree"],
        closing_at: 3.days.from_now
      },
      actor: @admin
    )

    markdown = render(discussion.topic)

    refute_includes markdown, "## Contexto"
    refute_includes markdown, "## Actividad"
    assert_includes markdown, "## Propuesta: Adopt the plan"
    assert_includes markdown, "### Resultados actuales"
    assert_includes markdown, "| Opción | Votos | % de votos emitidos | % de votantes elegibles | Votantes |"
    refute_includes markdown, "Anonymous voting"
    refute_includes markdown, "Votación anónima"
  end

  test "omits the group prefix for a direct thread" do
    topic = topics(:direct_topic)

    markdown = render(topic)

    expected = "# Discussion: #{topic.topicable.title} · #{topic.topicable.author.name}"
    assert_includes markdown, expected
    refute_match(/^group:/, markdown)
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

      assert_includes markdown, "group: \"#{@group.name}\""
      assert_includes markdown, "# Poll: Standalone decision · #{@admin.name}"
      assert_includes markdown, "## Poll"
      assert_includes markdown, "Choose one option."
      assert_equal 1, markdown.scan(/^## Poll$/).length
      refute_includes markdown, "## Proposal: Standalone decision"
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

  def create_poll(discussion, **params)
    PollService.create(
      params: {
        topic_id: discussion.topic_id,
        title: "Adopt the plan",
        poll_type: "proposal",
        poll_option_names: ["Agree", "Disagree"],
        closing_at: 3.days.from_now
      }.merge(params),
      actor: @admin
    )
  end

  def cast_vote(poll, reason:, reason_format: "html", choice: "Agree")
    stance = poll.stances.latest.find_by!(participant_id: @member.id)
    stance.choice = choice
    stance.reason = reason
    stance.reason_format = reason_format
    StanceService.create(stance: stance, actor: @member)
    stance
  end

  def render(topic, user: @admin)
    ThreadMarkdownService.render(topic: topic.reload, user: user)
  end
end
