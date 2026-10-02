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

      assert markdown.start_with?("---\nkey: \"#{discussion.key}\"\ngroup: \"#{@group.name}\"\ncreated: \"")
      assert_includes markdown, "tags: [\"governance\",\"planning\"]"
      assert_match(/^# Discussion: A clearer thread · #{@admin.name} · 2026-07-15 10:00$/, markdown)
      refute_includes markdown, "**Thread type:**"
      refute_includes markdown, "**Group:**"
      refute_includes markdown, "## Context"
      refute_includes markdown, "## Activity"
      assert_includes markdown, "## Purpose"
      # Comments are blockquotes, and a reply continues the comment it answers.
      assert_match(/^> \*\*#{@member.name}\*\* · 2026-07-15 10:00 · #\d+\n>\n> ### First point\n>\n> We should proceed\.\n>\n> > \*\*#{@admin.name}\*\* · 2026-07-15 11:00 · #\d+\n> >\n> > I agree with this\.$/, markdown)
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

      assert_match(/^## Proposal: Adopt the plan · #{@admin.name} · 2026-07-15 10:00 · #\d+$/, markdown)
      assert_equal 1, markdown.scan(/^## Proposal: Adopt the plan/).length
      refute_includes markdown, "**Type:**"
      assert_includes markdown, "- **Status:** Closed"
      assert_includes markdown, "- **Options:** Agree; Disagree"
      assert_includes markdown, "### Current results"
      assert_match(/\| Agree\s+\| 1\s+\| 100%\s+\| 10%\s+\| #{@member.name}\s+\|/, markdown)
      assert_match(/\| Undecided\s+\| 9\s+\|\s+\| 90%\s+\| .*#{@admin.name}.*\|/, markdown)
      assert_match(/^> \*\*#{@member.name}\*\* voted \*\*Agree\*\* · 2026-07-15 10:00 · #\d+\n>\n> It addresses the main concern\.$/, markdown)
      refute_includes markdown, "\n- Agree\n"
      refute_includes markdown, "**Response:**"
      refute_includes markdown, "### Reason"
      assert_match(/^> \*\*#{@admin.name}\*\* shared an outcome · 2026-07-15 10:00 · #\d+$/, markdown)
      refute_includes markdown, "- **Status:** Current"
      assert_match(/shared an outcome · [^\n]+\n>\n> The plan was adopted\.$/, markdown)
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
    # Reactions end the item's header line, so they stay out of people's text.
    assert_match(/^> \*\*#{@admin.name}\*\* · [^\n]+ · #\d+ · 👍 #{[@admin.name, @member.name].sort.join(', ')}$/, markdown)
    assert_match(/^> \*\*#{@member.name}\*\* voted \*\*Agree\*\* · [^\n]+ · #\d+ · ❤️ #{@admin.name}$/, markdown)
    assert_match(/^> > \*\*#{@admin.name}\*\* · [^\n]+ · #\d+\n> >\n> > Can we confirm the participants\?$/, markdown)
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
    refute_includes open_markdown, " voted"
    refute_includes open_markdown, @member.name

    PollService.close(poll: poll, actor: @admin)
    closed_markdown = render(discussion.topic)
    assert_match(/\| Agree\s+\| 1\s+\| 100%\s+\| 10%\s+\| Anonymous\s+\|/, closed_markdown)
    assert_match(/\| Undecided\s+\| 9\s+\|\s+\| 90%\s+\| Anonymous\s+\|/, closed_markdown)
    assert_equal 1, closed_markdown.scan(/^## Proposal: Detached anonymous check/).length
    refute_includes closed_markdown, " voted"
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
      refute_includes markdown, " voted"
    end
  end

  test "until vote exports include votes and replies for non-voters and voters" do
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

    CommentService.create(comment: Comment.new(parent: stance, body: 'Early conversation'), actor: @member)

    hidden_markdown = render(discussion.topic, user: @admin)
    visible_markdown = render(discussion.topic, user: @member)

    refute_includes hidden_markdown, '_Hidden until the viewer votes._'
    assert_includes hidden_markdown, 'Visible after voting.'
    assert_includes hidden_markdown, 'Early conversation'
    assert_match(/^> \*\*#{@member.name}\*\* voted \*\*Agree\*\* · [^\n]+ · #\d+$/, hidden_markdown)
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

  test "nests replies under the item they answer, in the thread's order" do
    discussion = create_discussion
    poll = create_poll(discussion)
    stance = cast_vote(poll, reason: "<p>Vote reason.</p>")
    later = Comment.new(body: "<p>Later thread comment.</p>", body_format: "html", parent: discussion)
    CommentService.create(comment: later, actor: @member)
    reply = Comment.new(body: "<p>Reply to the vote.</p>", body_format: "html", parent: stance)
    CommentService.create(comment: reply, actor: @admin)
    nested = Comment.new(body: "<p>Reply to the reply.</p><p>Second paragraph.</p>", body_format: "html", parent: reply)
    CommentService.create(comment: nested, actor: @member)
    on_poll = Comment.new(body: "<p>Comment on the poll.</p>", body_format: "html", parent: poll)
    CommentService.create(comment: on_poll, actor: @member)

    markdown = render(discussion.topic)

    # Everything that belongs to the poll comes before the later thread
    # comment, as it does in the threaded view.
    assert_operator markdown.index("Comment on the poll."), :<, markdown.index("Later thread comment.")
    assert_includes markdown, <<~MARKDOWN.strip
      > Vote reason.
      >
      > > **#{@admin.name}** · #{stamp(reply)}
      > >
      > > Reply to the vote.
      >
      > > **#{@member.name}** · #{stamp(nested)}
      > >
      > > Reply to the reply.
      > >
      > > Second paragraph.

      > **#{@member.name}** · #{stamp(on_poll)}
      >
      > Comment on the poll.

      > **#{@member.name}** · #{stamp(later)}
      >
      > Later thread comment.
    MARKDOWN
    # The thread's maximum depth is 3, so the reply to the reply sits beside
    # it, as it does in the app.
    assert_equal 3, TopicItem.find_by!(itemable: nested).depth
  end

  test "lists voters who have not set a name by their username" do
    nameless = User.create!(email: "nameless-voter@example.com", email_verified: true)
    @group.add_member!(nameless)
    discussion = create_discussion
    poll = create_poll(discussion)

    undecided_markdown = render(discussion.topic)
    assert_match(/\| Undecided\s+\|[^\n]*#{nameless.username}/, undecided_markdown)

    stance = poll.stances.latest.find_by!(participant_id: nameless.id)
    stance.choice = "Agree"
    stance.reason = "Works for me."
    StanceService.create(stance: stance, actor: nameless)

    voted_markdown = render(discussion.topic)
    assert_match(/\| Agree\s+\|[^\n]*#{nameless.username}/, voted_markdown)
    assert_match(/^> \*\*#{nameless.username}\*\* voted \*\*Agree\*\* · /, voted_markdown)
  end

  test "keeps replies to a removed comment nested under a placeholder" do
    discussion = create_discussion
    comment = Comment.new(body: "<p>Removed text.</p>", body_format: "html", parent: discussion)
    CommentService.create(comment: comment, actor: @member)
    CommentService.create(comment: Comment.new(body: "<p>Still here.</p>", body_format: "html", parent: comment), actor: @admin)
    comment.discard!

    markdown = render(discussion.topic)

    refute_includes markdown, "Removed text."
    assert_match(/^> _Removed_ · [^\n]+ · #\d+\n>\n> > \*\*#{@admin.name}\*\* · [^\n]+\n> >\n> > Still here\.$/, markdown)
  end

  test "marks changed votes as superseded" do
    discussion = create_discussion
    poll = create_poll(discussion)
    first = cast_vote(poll, reason: "<p>First thoughts.</p>")
    # A change after people may have seen the vote keeps the earlier one.
    travel 20.minutes
    StanceService.update(stance: first, actor: @member, params: {stance_choices_attributes: [{poll_option_id: poll.poll_options.find_by!(name: "Disagree").id}], reason: "<p>Changed my mind.</p>", reason_format: "html"})

    markdown = render(discussion.topic)

    assert_match(/voted \*\*Agree\*\* \(superseded\) · /, markdown)
    assert_match(/voted \*\*Disagree\*\* · /, markdown)
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

  def cast_vote(poll, reason:, choice: "Agree")
    stance = poll.stances.latest.find_by!(participant_id: @member.id)
    stance.choice = choice
    stance.reason = reason
    stance.reason_format = "html"
    StanceService.create(stance: stance, actor: @member)
    stance
  end

  def stamp(record)
    item = TopicItem.find_by!(itemable: record)
    "#{item.created_at.utc.strftime('%Y-%m-%d %H:%M')} · ##{item.sequence_id}"
  end

  def render(topic, user: @admin)
    ThreadMarkdownService.render(topic: topic.reload, user: user)
  end
end
