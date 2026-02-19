require "test_helper"

class PagesPhlexTest < ActiveSupport::TestCase
  def setup
    super
    @group = groups(:test_group)
    @user = users(:discussion_author)
    @group.add_admin!(@user)

    @recipient = LoggedOutUser.new(
      locale: "en",
      time_zone: "Pacific/Auckland",
      date_time_pref: "iso"
    )

    @discussion = Discussion.create!(
      title: "Pages Test Discussion",
      description: "<p>Discussion body for pages test</p>",
      description_format: "html",
      private: true,
      author: @user,
      group: @group
    )
    @discussion.create_missing_created_event!

    ActionMailer::Base.deliveries.clear
  end

  def render_phlex(component)
    ApplicationController.renderer.render(component, layout: false)
  end

  # ── DiscussionShow ──────────────────────────────────────────────

  test "discussion show renders title and group name" do
    pagination = { limit: 10, offset: 0 }
    output = render_phlex(Views::Discussions::Show.new(
      discussion: @discussion, recipient: @recipient, pagination: pagination
    ))

    assert_includes output, "Pages Test Discussion"
    assert_includes output, @group.full_name
    assert_includes output, @user.name
  end

  test "discussion show renders comment thread items" do
    comment = Comment.create!(
      body: "Test comment in pages",
      body_format: "md",
      parent: @discussion,
      author: @user
    )
    comment.events.create!(kind: :new_comment, user: @user, topic: @discussion.topic, created_at: comment.created_at)

    pagination = { limit: 10, offset: 0 }
    output = render_phlex(Views::Discussions::Show.new(
      discussion: @discussion.reload, recipient: @recipient, pagination: pagination
    ))

    assert_includes output, "Test comment in pages"
    assert_includes output, @user.name
  end

  test "discussion show renders poll created thread items" do
    poll = Poll.create!(
      title: "Pages Test Proposal",
      poll_type: "proposal",
      closing_at: 3.days.from_now,
      group: @group,
      discussion: @discussion,
      author: @user,
      poll_option_names: %w[agree disagree abstain]
    )
    poll.create_missing_created_event!

    pagination = { limit: 10, offset: 0 }
    output = render_phlex(Views::Discussions::Show.new(
      discussion: @discussion.reload, recipient: @recipient, pagination: pagination
    ))

    assert_includes output, "Pages Test Proposal"
  end

  test "discussion show renders stance created thread items" do
    poll = Poll.create!(
      title: "Stance Test Proposal",
      poll_type: "proposal",
      closing_at: 3.days.from_now,
      group: @group,
      discussion: @discussion,
      author: @user,
      poll_option_names: %w[agree disagree abstain],
      specified_voters_only: true
    )
    poll.create_missing_created_event!

    agree_option = poll.poll_options.find_by!(name: I18n.t("poll_proposal_options.agree"))
    stance = poll.stances.build(participant: @user)
    stance.stance_choices.build(poll_option: agree_option, score: 1)
    stance.save!
    stance.events.create!(kind: :stance_created, user: @user, topic: @discussion.topic, created_at: stance.created_at)

    pagination = { limit: 10, offset: 0 }
    output = render_phlex(Views::Discussions::Show.new(
      discussion: @discussion.reload, recipient: @recipient, pagination: pagination
    ))

    assert_includes output, @user.name
    assert_includes output, "stance-created"
  end

  # ── ThreadItems::NewComment ─────────────────────────────────────

  test "new comment component renders" do
    comment = Comment.create!(
      body: "Standalone comment test",
      body_format: "md",
      parent: @discussion,
      author: @user
    )
    comment.create_missing_created_event!
    item = comment.created_event

    output = render_phlex(Views::Discussions::ThreadItems::NewComment.new(item: item, current_user: @recipient))

    assert_includes output, "Standalone comment test"
    assert_includes output, @user.name
    assert_includes output, "new-comment"
  end

  # ── ThreadItems::PollCreated ────────────────────────────────────

  test "poll created component renders for proposal" do
    poll = Poll.create!(
      title: "Poll Created Component Test",
      poll_type: "proposal",
      closing_at: 3.days.from_now,
      group: @group,
      discussion: @discussion,
      author: @user,
      poll_option_names: %w[agree disagree abstain]
    )
    poll.create_missing_created_event!
    item = poll.created_event

    output = render_phlex(Views::Discussions::ThreadItems::PollCreated.new(item: item, current_user: @recipient))

    assert_includes output, "Poll Created Component Test"
    assert_includes output, @user.name
    assert_includes output, "poll-created"
  end

  # ── ThreadItems::StanceCreated ──────────────────────────────────

  test "stance created component renders for proposal" do
    poll = Poll.create!(
      title: "Stance Proposal",
      poll_type: "proposal",
      closing_at: 3.days.from_now,
      group: @group,
      discussion: @discussion,
      author: @user,
      poll_option_names: %w[agree disagree abstain],
      specified_voters_only: true
    )
    poll.create_missing_created_event!

    agree_option = poll.poll_options.find_by!(name: I18n.t("poll_proposal_options.agree"))
    stance = poll.stances.build(participant: @user)
    stance.stance_choices.build(poll_option: agree_option, score: 1)
    stance.save!
    stance.create_missing_created_event!
    item = stance.created_event

    output = render_phlex(Views::Discussions::ThreadItems::StanceCreated.new(item: item, current_user: @recipient))

    assert_includes output, @user.name
    assert_includes output, "stance-created"
  end

  test "stance created component renders vote removed when revoked" do
    poll = Poll.create!(
      title: "Revoked Stance Proposal",
      poll_type: "proposal",
      closing_at: 3.days.from_now,
      group: @group,
      discussion: @discussion,
      author: @user,
      poll_option_names: %w[agree disagree abstain],
      specified_voters_only: true
    )
    poll.create_missing_created_event!

    agree_option = poll.poll_options.find_by!(name: I18n.t("poll_proposal_options.agree"))
    stance = poll.stances.build(participant: @user)
    stance.stance_choices.build(poll_option: agree_option, score: 1)
    stance.save!
    stance.update_column(:revoked_at, Time.current)
    stance.create_missing_created_event!
    item = stance.created_event

    output = render_phlex(Views::Discussions::ThreadItems::StanceCreated.new(item: item, current_user: @recipient, kind: :created))

    assert_includes output, I18n.t("poll_common_votes_panel.vote_removed")
  end

  # ── ThreadItems::Removed ────────────────────────────────────────

  test "removed component renders" do
    comment = Comment.create!(
      body: "Will be discarded",
      body_format: "md",
      parent: @discussion,
      author: @user
    )
    comment.create_missing_created_event!
    item = comment.created_event

    output = render_phlex(Views::Discussions::ThreadItems::Removed.new(item: item, current_user: @recipient))

    assert_includes output, "item-removed"
    assert_includes output, I18n.t("thread_item.removed")
  end

  # ── StanceBody ──────────────────────────────────────────────────

  test "stance body renders for poll type" do
    poll = Poll.create!(
      title: "Poll Type Stance",
      poll_type: "poll",
      closing_at: 3.days.from_now,
      group: @group,
      discussion: @discussion,
      author: @user,
      poll_option_names: %w[Apple Banana],
      specified_voters_only: true
    )
    poll.create_missing_created_event!

    apple_option = poll.poll_options.find_by!(name: "Apple")
    stance = poll.stances.build(participant: @user)
    stance.stance_choices.build(poll_option: apple_option, score: 1)
    stance.save!

    output = render_phlex(Views::Discussions::StanceBody.new(
      stance: stance, voter: @user, poll: poll, current_user: @recipient
    ))

    assert_includes output, @user.name
    assert_includes output, "Apple"
  end

  test "stance body renders for dot_vote type" do
    poll = Poll.create!(
      title: "Dot Vote Stance",
      poll_type: "dot_vote",
      closing_at: 3.days.from_now,
      group: @group,
      discussion: @discussion,
      author: @user,
      poll_option_names: %w[Red Blue],
      dots_per_person: 8,
      specified_voters_only: true
    )
    poll.create_missing_created_event!

    red_option = poll.poll_options.find_by!(name: "Red")
    blue_option = poll.poll_options.find_by!(name: "Blue")
    stance = poll.stances.build(participant: @user)
    stance.stance_choices.build(poll_option: red_option, score: 5)
    stance.stance_choices.build(poll_option: blue_option, score: 3)
    stance.save!

    output = render_phlex(Views::Discussions::StanceBody.new(
      stance: stance, voter: @user, poll: poll, current_user: @recipient
    ))

    assert_includes output, @user.name
    assert_includes output, "Red"
    assert_includes output, "Blue"
  end

  test "stance body renders for score type" do
    poll = Poll.create!(
      title: "Score Stance",
      poll_type: "score",
      closing_at: 3.days.from_now,
      group: @group,
      discussion: @discussion,
      author: @user,
      poll_option_names: %w[Alpha Beta],
      max_score: 9,
      specified_voters_only: true
    )
    poll.create_missing_created_event!

    alpha_option = poll.poll_options.find_by!(name: "Alpha")
    stance = poll.stances.build(participant: @user)
    stance.stance_choices.build(poll_option: alpha_option, score: 7)
    stance.save!

    output = render_phlex(Views::Discussions::StanceBody.new(
      stance: stance, voter: @user, poll: poll, current_user: @recipient
    ))

    assert_includes output, @user.name
    assert_includes output, "Alpha"
  end

  test "stance body renders for ranked_choice type" do
    poll = Poll.create!(
      title: "Ranked Choice Stance",
      poll_type: "ranked_choice",
      closing_at: 3.days.from_now,
      group: @group,
      discussion: @discussion,
      author: @user,
      poll_option_names: %w[First Second Third],
      minimum_stance_choices: 3,
      specified_voters_only: true
    )
    poll.create_missing_created_event!

    first_option = poll.poll_options.find_by!(name: "First")
    second_option = poll.poll_options.find_by!(name: "Second")
    stance = poll.stances.build(participant: @user)
    stance.stance_choices.build(poll_option: first_option, score: 2)
    stance.stance_choices.build(poll_option: second_option, score: 1)
    stance.save!

    output = render_phlex(Views::Discussions::StanceBody.new(
      stance: stance, voter: @user, poll: poll, current_user: @recipient
    ))

    assert_includes output, @user.name
    assert_includes output, "First"
    assert_includes output, "Second"
  end

  # ── GroupShow ───────────────────────────────────────────────────

  test "group show renders group name and description" do
    output = render_phlex(Views::Groups::Show.new(group: @group, recipient: @recipient))

    assert_includes output, @group.full_name
    assert_includes output, "group-page"
  end

  # ── GroupExport ─────────────────────────────────────────────────

  test "group export renders with export tables" do
    exporter = GroupExporter.new(@group)
    output = render_phlex(Views::Groups::Export.new(exporter: exporter))

    assert_includes output, "Export for #{@group.full_name}"
    assert_includes output, "Groups"
    assert_includes output, "Memberships"
    assert_includes output, "Discussions"
    assert_includes output, "Comments"
    assert_includes output, "Polls"
    assert_includes output, "Stances"
  end

  # ── PollExport ──────────────────────────────────────────────────

  test "poll export renders poll and responses" do
    poll = Poll.create!(
      title: "Export Test Proposal",
      poll_type: "proposal",
      closing_at: 3.days.from_now,
      group: @group,
      discussion: @discussion,
      author: @user,
      poll_option_names: %w[agree disagree abstain]
    )
    poll.create_missing_created_event!

    exporter = PollExporter.new(poll)
    output = render_phlex(Views::Polls::Export.new(
      poll: poll, exporter: exporter, recipient: @recipient
    ))

    assert_includes output, "Export Test Proposal"
    assert_includes output, "poll-created"
  end

  # ── ExportTable ─────────────────────────────────────────────────

  test "export table renders with records" do
    exporter = GroupExporter.new(@group)
    records = exporter.groups
    fields = exporter.group_fields

    output = render_phlex(Views::Groups::ExportTable.new(
      name: "Groups", records: records, fields: fields, exporter: exporter
    ))

    assert_includes output, "Groups (#{records.length})"
    assert_includes output, @group.name
  end

  test "export table renders empty when no records" do
    exporter = GroupExporter.new(@group)

    output = render_phlex(Views::Groups::ExportTable.new(
      name: "Outcomes", records: [], fields: exporter.group_fields, exporter: exporter
    ))

    assert_includes output, "Outcomes (0)"
    refute_includes output, "<tbody>"
  end
end
