require 'test_helper'

class ReportServiceTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @member = users(:member)
    @user = users(:user)
    @group = groups(:group)
  end

  def report(group_ids: [@group.id], start_at: 1.day.ago, end_at: 1.day.from_now)
    ReportService.new(interval: 'month', group_ids: group_ids, start_at: start_at, end_at: end_at)
  end

  def create_discussion(author: @admin, tags: [])
    DiscussionService.create(
      params: {title: "Test #{SecureRandom.hex(4)}", group_id: @group.id, tags: tags},
      actor: author
    )
  end

  def create_poll(author: @admin, tags: [], group: @group)
    poll = PollService.build(
      params: {
        poll_type: 'proposal',
        title: "Poll #{SecureRandom.hex(4)}",
        options: %w[agree disagree abstain],
        specified_voters_only: true,
        group_id: group.id,
        tags: tags,
        closing_at: 1.week.from_now
      },
      actor: author
    )
    poll.save!
    poll.create_missing_created_event!
    poll
  end

  def cast_stance(poll:, participant:)
    stance = Stance.new(poll: poll, participant: participant, latest: true)
    stance.choice = poll.poll_options.first.name
    stance.save!
    stance
  end

  def create_outcome(poll:, author: @admin)
    Outcome.create!(statement: "Decided", poll: poll, author: author, latest: true)
  end

  # --- existing test ---

  test "counts tagged threads participated in per user" do
    authored_by_admin = create_discussion(author: @admin, tags: ['alpha'])
    authored_by_user = create_discussion(author: @user, tags: ['alpha', 'beta'])
    CommentService.create(comment: Comment.new(body: "I participated", parent: authored_by_admin), actor: @member)
    CommentService.create(comment: Comment.new(body: "Again", parent: authored_by_admin), actor: @member)
    Reaction.create!(reactable: authored_by_user, user: @member, reaction: '+1')

    r = report

    assert_equal 1, r.tag_threads_per_user['alpha'][@admin.id]
    assert_equal 1, r.tag_threads_per_user['alpha'][@member.id]
    assert_equal 1, r.tag_threads_per_user['alpha'][@user.id]
    assert_equal 1, r.tag_threads_per_user['beta'][@user.id]
    assert_nil r.tag_threads_per_user['beta'][@member.id]

    assert_equal 1, r.tag_threads_authored_per_user['alpha'][@admin.id]
    assert_equal 1, r.tag_threads_authored_per_user['alpha'][@user.id]
    assert_equal 1, r.tag_threads_authored_per_user['beta'][@user.id]
    assert_nil r.tag_threads_authored_per_user['alpha'][@member.id]
  end

  # --- per-user counts ---

  test "counts discussions, comments, polls, stances, outcomes per user" do
    discussion = create_discussion(author: @admin)
    CommentService.create(comment: Comment.new(body: "hi", parent: discussion), actor: @member)
    poll = create_poll(author: @admin)
    cast_stance(poll: poll, participant: @member)
    create_outcome(poll: poll, author: @admin)

    r = report

    assert_equal 1, r.discussions_per_user[@admin.id]
    assert_equal 1, r.comments_per_user[@member.id]
    assert_equal 1, r.polls_per_user[@admin.id]
    assert_equal 1, r.stances_per_user[@member.id]
    assert_equal 1, r.outcomes_per_user[@admin.id]
  end

  test "counts activity per interval and totals" do
    discussion = create_discussion(author: @admin)
    CommentService.create(comment: Comment.new(body: "hi", parent: discussion), actor: @member)
    poll = create_poll(author: @admin)
    cast_stance(poll: poll, participant: @member)
    create_outcome(poll: poll, author: @admin)

    r = report
    interval_date = Time.zone.today.beginning_of_month
    interval = r.topics_per_interval.keys.find { |key| key.to_date == interval_date }

    assert_equal 2, r.topics_per_interval[interval]
    assert_equal 1, r.comments_per_interval[interval]
    assert_equal 1, r.polls_per_interval[interval]
    assert_equal 1, r.stances_per_interval[interval]
    assert_equal 1, r.outcomes_per_interval[interval]

    assert_equal 2, r.topics_count
    assert_equal 1, r.discussion_topics_count
    assert_equal 1, r.poll_topics_count
    assert_equal 1, r.polls_count
    assert_equal 1, r.polls_with_outcomes_count
  end

  # --- reactions ---

  test "counts reactions per user across reactable types" do
    discussion = create_discussion(author: @admin)
    comment = Comment.new(body: "hi", parent: discussion)
    CommentService.create(comment: comment, actor: @admin)
    poll = create_poll(author: @admin)
    stance = cast_stance(poll: poll, participant: @admin)
    outcome = create_outcome(poll: poll, author: @admin)

    Reaction.create!(reactable: discussion, user: @member, reaction: '+1')
    Reaction.create!(reactable: comment,    user: @member, reaction: '+1')
    Reaction.create!(reactable: poll,       user: @member, reaction: '+1')
    Reaction.create!(reactable: stance,     user: @member, reaction: '+1')
    Reaction.create!(reactable: outcome,    user: @member, reaction: '+1')

    r = report
    assert_equal 5, r.reactions_per_user[@member.id]
    assert_nil r.reactions_per_user[@admin.id]
  end

  test "counts activity per country" do
    @admin.update_column(:country, 'NZ')
    @user.update_column(:country, 'NZ')
    @member.update_column(:country, 'AU')

    discussion = create_discussion(author: @admin)
    CommentService.create(comment: Comment.new(body: "hi", parent: discussion), actor: @member)
    poll = create_poll(author: @admin)
    cast_stance(poll: poll, participant: @member)
    create_outcome(poll: poll, author: @admin)
    Reaction.create!(reactable: discussion, user: @member, reaction: '+1')

    r = report

    assert_equal 1, r.discussions_per_country['NZ']
    assert_equal 1, r.polls_per_country['NZ']
    assert_equal 1, r.outcomes_per_country['NZ']
    assert_equal 1, r.comments_per_country['AU']
    assert_equal 1, r.stances_per_country['AU']
    assert_equal 1, r.reactions_per_country['AU']
    assert_equal 2, r.users_per_country['NZ']
    assert_equal 1, r.users_per_country['AU']
    assert_includes r.countries, 'NZ'
    assert_includes r.countries, 'AU'
  end

  # --- tag_threads with poll participation ---

  test "counts tagged threads via poll stance and outcome" do
    poll = create_poll(author: @admin, tags: ['delta'])
    cast_stance(poll: poll, participant: @member)
    create_outcome(poll: poll, author: @user)

    r = report

    assert_equal 1, r.tag_threads_per_user['delta'][@admin.id]
    assert_equal 1, r.tag_threads_per_user['delta'][@member.id]
    assert_equal 1, r.tag_threads_per_user['delta'][@user.id]

    assert_equal 1, r.tag_threads_authored_per_user['delta'][@admin.id]
    assert_nil r.tag_threads_authored_per_user['delta'][@member.id]
    assert_nil r.tag_threads_authored_per_user['delta'][@user.id]
  end

  # --- tag_counts ---

  test "counts tags and returns sorted names" do
    create_discussion(author: @admin, tags: ['zeta', 'alpha'])
    create_discussion(author: @admin, tags: ['alpha'])

    r = report
    assert_equal 2, r.tag_counts['alpha']
    assert_equal 1, r.tag_counts['zeta']
    assert_equal %w[alpha zeta], r.tag_names
  end

  test "memoizes tag_counts so tag_names does not requery" do
    create_discussion(author: @admin, tags: ['alpha'])
    r = report
    counts = r.tag_counts
    assert_same counts, r.tag_counts
    assert_same counts, r.instance_variable_get(:@tag_counts)
  end

  # --- date range filtering ---

  test "excludes items created before start_at" do
    discussion = create_discussion(author: @admin)
    CommentService.create(comment: Comment.new(body: "old", parent: discussion), actor: @member)

    r = report(start_at: 1.hour.from_now, end_at: 1.day.from_now)

    assert_nil r.discussions_per_user[@admin.id]
    assert_nil r.comments_per_user[@member.id]
  end

  # --- group filtering ---

  test "excludes items from other groups" do
    other_group = Group.new(name: "Other #{SecureRandom.hex(4)}", group_privacy: 'secret')
    other_group.save!
    Membership.create!(user: @admin, group: other_group, accepted_at: Time.current, admin: true)
    DiscussionService.create(params: {title: "Other", group_id: other_group.id}, actor: @admin)

    r = report(group_ids: [@group.id])
    assert_nil r.discussions_per_user[@admin.id]
  end
end
