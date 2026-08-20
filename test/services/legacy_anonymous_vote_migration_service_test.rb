require "test_helper"

class LegacyAnonymousVoteMigrationServiceTest < ActiveSupport::TestCase
  setup do
    LegacyAnonymousVoteReason.delete_all
    @admin = users(:admin)
    @voter = users(:user)
    @poll = build_legacy_poll
  end

  test "normalizes HTML and Markdown reasons to readable plain text" do
    html = <<~HTML
      <p>Hello <strong>there</strong> <span data-mention-id="1">@Sam</span></p>
      <ul><li>First</li><li><a href="https://example.org">Second</a></li></ul>
      <p><a href="/rails/active_storage/blobs/example/file.pdf">file.pdf</a></p>
    HTML
    markdown = "Hello **there**\n\n- First\n- Second"

    assert_equal(
      "Hello there @Sam\n\n- First\n- Second",
      LegacyAnonymousVoteMigrationService.normalize_reason(html, "html")
    )
    assert_equal(
      "Hello there\n\n- First\n- Second",
      LegacyAnonymousVoteMigrationService.normalize_reason(markdown, "md")
    )
  end

  test "canonical results are ordered by option id" do
    results = LegacyAnonymousVoteMigrationService.send(:canonical_results, @poll)

    assert_equal results.pluck("id").sort, results.pluck("id")
  end

  test "migrates current votes, reasons, and a complete electorate" do
    first = cast_vote(
      user: @admin,
      option: @poll.poll_options.first,
      reason: "<p>Because <strong>this works</strong></p>",
      reason_format: "html"
    )
    second = cast_vote(user: @voter, option: @poll.poll_options.second)
    close_legacy_poll
    @poll.stance_receipts.update_all(vote_cast: true)

    assert_nil first.reload.participant_id
    assert_nil second.reload.participant_id
    result_before = canonical_results(@poll.reload)

    result = LegacyAnonymousVoteMigrationService.migrate!(poll: @poll)

    @poll.reload
    assert @poll.detached_anonymous?
    assert @poll.closed?
    refute_includes Poll.column_names, "legacy_anonymous"
    assert_equal 2, result[:ballots]
    assert_equal 1, result[:reasons]
    assert_equal 2, @poll.anonymous_ballots.count
    assert_equal 2, @poll.anonymous_ballot_choices.count
    assert_equal ["Because this works"], @poll.legacy_anonymous_vote_reasons.pluck(:body)
    assert_equal result_before, canonical_results(@poll)
    assert_empty @poll.stances
    assert_equal 2, @poll.anonymous_poll_voters.count
    assert @poll.anonymous_poll_voters.all? { |record| record.group_member.nil? }
    assert_equal 2, @poll.anonymous_poll_voters.where(ballot_submitted: true).count
    assert_equal(
      %w[anonymous_ballot_id body],
      LegacyAnonymousVoteReason.column_names.sort
    )
  end

  test "does not calculate STV input for another poll type" do
    cast_vote(user: @admin, option: @poll.poll_options.first)
    close_legacy_poll

    StvCountService.stub(:extract_ballots, ->(*) { flunk "did not expect STV input" }) do
      LegacyAnonymousVoteMigrationService.migrate!(poll: @poll)
    end

    assert @poll.reload.detached_anonymous?
  end

  test "enqueues conversion when a legacy poll closes" do
    assert_enqueued_with(job: MigrateLegacyAnonymousVotesWorker, args: [@poll.topic_id]) do
      close_legacy_poll
    end
  end

  test "cleanup repairs the poll topic before migration" do
    close_legacy_poll

    result = LegacyAnonymousVoteMigrationCleanupService.cleanup!(poll: @poll)

    assert_equal @poll.id, result[:poll_id]
    assert_equal @poll.topic_id, result[:topic_id]
    assert_equal 0, result[:detached_ballot_choice_mismatches]
    assert_equal 0, result[:removed_stance_choices]
  end

  test "cleanup removes only choices belonging to another poll" do
    other_poll = build_legacy_poll
    stance = cast_vote(user: @admin, option: @poll.poll_options.first)
    StanceChoice.insert_all!([{
      stance_id: stance.id,
      poll_option_id: other_poll.poll_options.first.id,
      score: 1
    }])
    close_legacy_poll
    results_before = canonical_results(@poll.reload)

    result = LegacyAnonymousVoteMigrationCleanupService.cleanup!(poll: @poll)

    assert_equal 1, result[:removed_stance_choices]
    assert Stance.exists?(stance.id)
    assert_equal [@poll.poll_options.first.id], stance.stance_choices.reload.pluck(:poll_option_id)
    assert_equal results_before, canonical_results(@poll.reload)
  end

  test "migration preserves source poll results when removing a foreign choice" do
    other_poll = build_legacy_poll
    valid_stance = cast_vote(user: @admin, option: @poll.poll_options.first)
    invalid_stance = cast_vote(user: @voter, option: @poll.poll_options.second)
    invalid_stance.stance_choices.first.update_columns(poll_option_id: other_poll.poll_options.first.id)
    close_legacy_poll
    @poll.update_counts!
    results_before = canonical_results(@poll.reload)

    result = LegacyAnonymousVoteMigrationService.migrate!(poll: @poll)

    assert_equal 2, result[:ballots]
    assert_not Stance.exists?(invalid_stance.id)
    assert_not Stance.exists?(valid_stance.id)
    assert_equal [@poll.poll_options.first.id], @poll.anonymous_ballot_choices.pluck(:poll_option_id)
    assert_equal results_before, canonical_results(@poll.reload)
  end

  test "migration preserves results containing duplicate choices" do
    valid_stance = cast_vote(user: @admin, option: @poll.poll_options.first)
    invalid_stance = cast_vote(user: @voter, option: @poll.poll_options.second)
    StanceChoice.insert_all!([{
      stance_id: invalid_stance.id,
      poll_option_id: @poll.poll_options.second.id,
      score: 1
    }])
    close_legacy_poll
    @poll.update_counts!
    results_before = canonical_results(@poll.reload)

    result = LegacyAnonymousVoteMigrationService.migrate!(poll: @poll)

    assert_equal 3, result[:ballots]
    assert_not Stance.exists?(invalid_stance.id)
    assert_not Stance.exists?(valid_stance.id)
    assert_equal(
      [@poll.poll_options.first.id, @poll.poll_options.second.id, @poll.poll_options.second.id],
      @poll.anonymous_ballot_choices.order(:poll_option_id).pluck(:poll_option_id)
    )
    assert_equal results_before, canonical_results(@poll.reload)
  end

  test "rolls back rather than replacing observed results with inconsistent choice rows" do
    stance = cast_vote(user: @admin, option: @poll.poll_options.first)
    close_legacy_poll
    results_before = canonical_results(@poll.reload)
    stance.stance_choices.first.update_columns(score: 2)

    error = assert_raises(LegacyAnonymousVoteMigrationService::MigrationError) do
      LegacyAnonymousVoteMigrationService.migrate!(poll: @poll)
    end

    assert_match(/verification failed: results/, error.message)
    assert @poll.reload.stance?
    assert Stance.exists?(stance.id)
    assert_empty @poll.anonymous_ballots
    assert_equal results_before, canonical_results(@poll)
  end

  test "migration detaches identified late votes and removes their identified events" do
    stance = cast_vote(user: @admin, option: @poll.poll_options.first)
    close_legacy_poll
    stance.update_columns(participant_id: @admin.id)
    Event.where(eventable_type: "Stance", eventable_id: stance.id).update_all(user_id: @admin.id)

    result = LegacyAnonymousVoteMigrationService.migrate!(poll: @poll)

    assert_equal 1, result[:ballots]
    assert_not Stance.exists?(stance.id)
    assert_not Event.exists?(eventable_type: "Stance", eventable_id: stance.id)
    assert_equal 1, @poll.reload.anonymous_ballots.count
  end

  test "cleanup rejects detached ballot choices belonging to another poll" do
    detached_poll = PollService.create(
      params: {
        title: "Detached anonymous poll",
        poll_type: "proposal",
        closing_at: 3.days.from_now,
        group_id: groups(:group).id,
        anonymous: true,
        poll_option_names: ["Agree", "Disagree"]
      },
      actor: @admin
    )
    ballot_id = SecureRandom.uuid
    AnonymousBallot.insert_all!([{id: ballot_id, poll_id: detached_poll.id, none_of_the_above: false}])
    AnonymousBallotChoice.insert_all!([{
      anonymous_ballot_id: ballot_id,
      poll_option_id: @poll.poll_options.first.id,
      score: 1
    }])
    close_legacy_poll

    error = assert_raises(LegacyAnonymousVoteMigrationCleanupService::CleanupError) do
      LegacyAnonymousVoteMigrationCleanupService.cleanup!(poll: @poll)
    end

    assert_match(/detached ballot choices for another poll/, error.message)
    assert_equal 1, LegacyAnonymousVoteMigrationCleanupService.detached_ballot_choice_mismatches(@poll.id).length
  end

  test "does not migrate superseded, revoked, undecided, or redacted reasons" do
    current = cast_vote(
      user: @admin,
      option: @poll.poll_options.first,
      reason: "Current reason"
    )
    current.update_columns(redacted_at: Time.current)

    superseded = Stance.create!(
      poll: @poll,
      participant: @voter,
      cast_at: Time.current,
      latest: false,
      reason: "Superseded reason",
      stance_choices_attributes: [{poll_option_id: @poll.poll_options.second.id, score: 1}]
    )
    revoked = Stance.create!(
      poll: @poll,
      participant: @voter,
      cast_at: Time.current,
      latest: false,
      revoked_at: Time.current,
      reason: "Revoked reason",
      stance_choices_attributes: [{poll_option_id: @poll.poll_options.second.id, score: 1}]
    )
    undecided = Stance.create!(poll: @poll, participant: @voter, latest: true)
    close_legacy_poll

    LegacyAnonymousVoteMigrationService.migrate!(poll: @poll)

    assert_equal 1, @poll.reload.anonymous_ballots.count
    assert_empty @poll.legacy_anonymous_vote_reasons
    assert_not Stance.exists?(current.id)
    assert_not Stance.exists?(superseded.id)
    assert_not Stance.exists?(revoked.id)
    assert_not Stance.exists?(undecided.id)
  end

  test "moves reason files to the poll and detaches stance-owned rich content" do
    stance = cast_vote(user: @admin, option: @poll.poll_options.first, reason: "Reason with file")
    stance_event = Event.where(eventable: stance).first
    close_legacy_poll
    stance_event.reload

    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("legacy file"),
      filename: "legacy.txt",
      content_type: "text/plain"
    )
    stance.files.attach(blob)
    comment = Comment.create!(parent: stance, author: @voter, body: "Reply retained as poll discussion")
    comment_event = Events::NewComment.publish!(comment)
    Reaction.create!(reactable: stance, user: @voter, reaction: "agree")
    Bookmark.create!(bookmarkable: stance, user: @voter)
    Translation.create!(translatable: stance, language: "fr", fields: {reason: "Raison"})
    task = Task.create!(record: stance, author: @admin, doer: @admin, uid: 123, name: "Legacy task", done: false)
    TasksUser.create!(task: task, user: @admin)
    PaperTrail::Version.create!(item_type: "Stance", item_id: stance.id, event: "update")
    PgSearch::Document.create!(searchable_type: "Stance", searchable_id: stance.id)

    LegacyAnonymousVoteMigrationService.migrate!(poll: @poll)

    attachment = ActiveStorage::Attachment.find_by!(blob_id: blob.id)
    assert_equal "Poll", attachment.record_type
    assert_equal @poll.id, attachment.record_id
    assert_equal "files", attachment.name
    assert_equal @poll.created_at.to_i, attachment.created_at.to_i
    assert_equal ["legacy.txt"], @poll.reload.attachments.pluck("filename")
    assert_equal "Poll", comment.reload.parent_type
    assert_equal @poll.id, comment.parent_id
    assert_equal @poll.created_event.id, comment_event.reload.parent_id
    assert_equal @poll.created_event.depth + 1, comment_event.depth
    assert comment_event.position_key.start_with?("#{@poll.created_event.position_key}-")
    assert_equal(
      Event.where(topic_id: @poll.topic_id, parent_id: @poll.created_event.id).count,
      @poll.created_event.reload.child_count
    )
    assert_empty @poll.topic.items.where(eventable_type: "Stance")
    assert_not Reaction.exists?(reactable_type: "Stance", reactable_id: stance.id)
    assert_not Bookmark.exists?(bookmarkable_type: "Stance", bookmarkable_id: stance.id)
    assert_not Translation.exists?(translatable_type: "Stance", translatable_id: stance.id)
    assert_not Task.exists?(task.id)
    assert_not PaperTrail::Version.exists?(item_type: "Stance", item_id: stance.id)
    assert_not PgSearch::Document.exists?(searchable_type: "Stance", searchable_id: stance.id)
    assert_not Event.exists?(stance_event.id)
  end

  test "repairs the topic tree after removing stance thread items" do
    @poll.create_missing_created_event!
    first = cast_vote(user: @admin, option: @poll.poll_options.first, reason: "First reason")
    second = cast_vote(user: @voter, option: @poll.poll_options.second, reason: "Second reason")
    stance_event_ids = Event.where(eventable_type: "Stance", eventable_id: [first.id, second.id]).pluck(:id)
    poll_event = @poll.created_event
    close_legacy_poll

    assert_equal 2, Event.where(id: stance_event_ids, parent_id: poll_event.id).count

    LegacyAnonymousVoteMigrationService.migrate!(poll: @poll)

    poll_event.reload
    assert_empty Event.where(id: stance_event_ids)
    assert_equal(
      Event.where(topic_id: @poll.topic_id, parent_id: poll_event.id).count,
      poll_event.child_count
    )
    @poll.topic.items.where.not(parent_id: nil).find_each do |event|
      parent = Event.find_by(id: event.parent_id, topic_id: @poll.topic_id)
      assert parent, "event #{event.id} has a missing topic parent"
      assert_equal parent.depth + 1, event.depth
      assert event.position_key.start_with?("#{parent.position_key}-")
    end
  end

  test "repairs every topic affected by a cross-topic stance event" do
    stance = cast_vote(user: @admin, option: @poll.poll_options.first)
    close_legacy_poll
    stance_event = Event.find_by!(eventable: stance)
    other_topic = discussions(:public_discussion).topic
    other_parent = discussions(:public_discussion).created_event
    stance_event.update_columns(topic_id: other_topic.id, parent_id: other_parent.id)
    other_parent.update_columns(child_count: other_parent.child_count + 1)

    LegacyAnonymousVoteMigrationService.migrate!(poll: @poll)

    assert_not Event.exists?(stance_event.id)
    assert_equal(
      Event.where(topic_id: other_topic.id, parent_id: other_parent.id).count,
      other_parent.reload.child_count
    )
    TopicService.verify_integrity!(@poll.topic_id)
    TopicService.verify_integrity!(other_topic.id)
  end

  test "rejects an open poll and leaves its stance untouched" do
    stance = cast_vote(user: @admin, option: @poll.poll_options.first)

    error = assert_raises(LegacyAnonymousVoteMigrationService::MigrationError) do
      LegacyAnonymousVoteMigrationService.migrate!(poll: @poll)
    end

    assert_match(/not closed/, error.message)
    assert Stance.exists?(stance.id)
    assert_empty @poll.anonymous_ballots
  end

  test "preserves participation counts without inventing an incomplete electorate" do
    cast_vote(user: @admin, option: @poll.poll_options.first)
    cast_vote(user: @voter, option: @poll.poll_options.second)
    close_legacy_poll
    @poll.stance_receipts.update_all(vote_cast: nil)
    counts_before = [@poll.voters_count, @poll.undecided_voters_count]

    LegacyAnonymousVoteMigrationService.migrate!(poll: @poll)

    @poll.reload
    assert_empty @poll.anonymous_poll_voters
    assert_equal counts_before, [@poll.voters_count, @poll.undecided_voters_count]
    assert_equal 2, @poll.anonymous_ballots.count
  end

  test "rolls back the whole poll when detached verification fails" do
    stance = cast_vote(user: @admin, option: @poll.poll_options.first, reason: "Keep me on rollback")
    close_legacy_poll

    LegacyAnonymousVoteMigrationService.stub(
      :verify_detached_data!,
      ->(_poll, _baseline) { raise LegacyAnonymousVoteMigrationService::MigrationError, "forced mismatch" }
    ) do
      assert_raises(LegacyAnonymousVoteMigrationService::MigrationError) do
        LegacyAnonymousVoteMigrationService.migrate!(poll: @poll)
      end
    end

    @poll.reload
    assert @poll.stance?
    assert Stance.exists?(stance.id)
    assert_empty @poll.anonymous_ballots
    assert_empty @poll.legacy_anonymous_vote_reasons
  end

  test "migrates a closed poll with no submitted votes" do
    close_legacy_poll

    result = LegacyAnonymousVoteMigrationService.migrate!(poll: @poll)

    assert_equal 1, result[:polls]
    assert_equal 0, result[:ballots]
    assert @poll.reload.detached_anonymous?
    assert_empty @poll.anonymous_ballots
    assert_empty @poll.stances
  end

  test "preserves STV input and count results" do
    poll = Poll.create!(
      title: "Legacy anonymous STV poll",
      poll_type: "stv",
      closing_at: 3.days.from_now,
      opened_at: 1.day.ago,
      topic: discussions(:discussion).topic,
      author: @admin,
      anonymous: true,
      hide_results: "until_closed",
      stv_seats: 1,
      stv_method: "scottish",
      stv_quota: "droop",
      poll_option_names: %w[A B C]
    )
    rankings = [
      [@admin, %w[A B C]],
      [@voter, %w[B A C]],
      [users(:alien), %w[C A B]]
    ]
    options_by_name = poll.poll_options.index_by(&:name)
    rankings.each do |user, option_names|
      Stance.create!(
        poll: poll,
        participant: user,
        cast_at: Time.current,
        stance_choices_attributes: option_names.each_with_index.map { |name, index|
          {poll_option_id: options_by_name.fetch(name).id, score: index + 1}
        }
      )
    end
    poll.update_counts!
    PollService.do_closing_work(poll: poll)
    input_before = StvCountService.extract_ballots(poll.reload).sort
    result_before = StvCountService.count(poll).deep_stringify_keys

    LegacyAnonymousVoteMigrationService.migrate!(poll: poll)

    assert_equal input_before, StvCountService.extract_ballots(poll.reload).sort
    assert_equal result_before, StvCountService.count(poll).deep_stringify_keys
    assert poll.detached_anonymous?
    assert_empty poll.stances
  end

  test "post-migration audit verifies migrated data" do
    baseline = LegacyAnonymousVoteMigrationAuditService.reference_baseline
    cast_vote(user: @admin, option: @poll.poll_options.first, reason: "A retained reason")
    close_legacy_poll

    LegacyAnonymousVoteMigrationService.migrate!(poll: @poll)

    result = LegacyAnonymousVoteMigrationAuditService.audit(dangling_baseline: baseline)
    assert result[:ok], result[:errors].inspect
    assert_equal 1, result.dig(:counts, :detached_polls)
    assert_equal 1, result.dig(:counts, :detached_votes)
    assert_equal 1, result.dig(:counts, :legacy_reasons)
  end

  test "post-migration audit accepts extra ballots used to preserve duplicate legacy choices" do
    baseline = LegacyAnonymousVoteMigrationAuditService.reference_baseline
    stance = cast_vote(user: @admin, option: @poll.poll_options.first)
    StanceChoice.insert_all!([{
      stance_id: stance.id,
      poll_option_id: @poll.poll_options.first.id,
      score: 1
    }])
    close_legacy_poll
    @poll.update_counts!

    LegacyAnonymousVoteMigrationService.migrate!(poll: @poll)

    assert_operator @poll.reload.anonymous_ballots.count, :>, @poll.decided_voters_count
    result = LegacyAnonymousVoteMigrationAuditService.audit(dangling_baseline: baseline)
    assert result[:ok], result[:errors].inspect
  end

  test "post-migration audit accepts native detached electorates" do
    baseline = LegacyAnonymousVoteMigrationAuditService.reference_baseline
    poll = PollService.create(
      params: {
        title: "Native detached anonymous poll",
        poll_type: "proposal",
        closing_at: 3.days.from_now,
        group_id: groups(:group).id,
        anonymous: true,
        poll_option_names: ["Agree", "Disagree"]
      },
      actor: @admin
    )
    PollService.close(poll: poll, actor: @admin)

    assert poll.reload.detached_anonymous?
    assert poll.anonymous_poll_voters.where.not(group_member: nil).exists?
    result = LegacyAnonymousVoteMigrationAuditService.audit(dangling_baseline: baseline)
    assert result[:ok], result[:errors].inspect
  end

  test "post-migration audit detects changed result caches and dangling stance references" do
    baseline = LegacyAnonymousVoteMigrationAuditService.reference_baseline
    stance = cast_vote(user: @admin, option: @poll.poll_options.first)
    close_legacy_poll

    LegacyAnonymousVoteMigrationService.migrate!(poll: @poll)
    @poll.poll_options.first.update_columns(total_score: 99)
    Reaction.insert_all!(
      [{
        reactable_type: "Stance",
        reactable_id: stance.id,
        user_id: @voter.id,
        reaction: "agree",
        created_at: Time.current,
        updated_at: Time.current
      }]
    )

    result = LegacyAnonymousVoteMigrationAuditService.audit(dangling_baseline: baseline)
    assert_not result[:ok]
    assert_includes result.dig(:errors, :detached_poll_results).first[:failures], "option #{@poll.poll_options.first.id} score differs"
    assert_equal(
      {baseline: baseline.fetch(:reactions, 0), current: baseline.fetch(:reactions, 0) + 1},
      result.dig(:errors, :dangling_stance_reference_increases, :reactions)
    )
  end

  private

  def build_legacy_poll
    Poll.create!(
      title: "Legacy anonymous poll",
      poll_type: "proposal",
      closing_at: 3.days.from_now,
      opened_at: 1.day.ago,
      topic: discussions(:discussion).topic,
      author: @admin,
      anonymous: true,
      hide_results: "until_closed",
      poll_option_names: ["Agree", "Disagree"]
    )
  end

  def cast_vote(user:, option:, reason: nil, reason_format: "md")
    stance = Stance.new(
      poll: @poll,
      reason: reason,
      reason_format: reason_format,
      stance_choices_attributes: [{poll_option_id: option.id, score: 1}]
    )
    StanceService.create(stance: stance, actor: user)
    stance
  end

  def close_legacy_poll
    PollService.do_closing_work(poll: @poll)
    @poll.reload
  end

  def canonical_results(poll)
    PollService.calculate_results(poll, poll.poll_options.reload).map do |result|
      result.to_h.stringify_keys.slice(*LegacyAnonymousVoteMigrationService::RESULT_FIELDS)
    end
  end
end
