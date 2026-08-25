require "test_helper"

class AnonymousBallotServiceTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @voter = users(:user)
    @group = groups(:group)
    @poll = PollService.create(
      params: {
        title: "Detached anonymous poll",
        poll_type: "proposal",
        closing_at: 3.days.from_now,
        group_id: @group.id,
        anonymous: true,
        poll_option_names: ["Agree", "Disagree"]
      },
      actor: @admin
    )
  end

  test "new anonymous polls use detached ballots and a named electorate" do
    assert @poll.detached_anonymous?
    assert_equal "until_closed", @poll.hide_results
    assert_equal "disabled", @poll.stance_reason_required
    assert_empty @poll.stances
    assert @poll.anonymous_poll_voters.exists?(voter_id: @voter.id)
  end

  test "notified specified-voter invitation rolls back when notification creation fails" do
    poll = PollService.create(
      params: {
        title: "Atomic anonymous invitation",
        poll_type: "proposal",
        closing_at: 3.days.from_now,
        group_id: @group.id,
        anonymous: true,
        specified_voters_only: true,
        poll_option_names: [ "Agree", "Disagree" ]
      },
      actor: @admin
    )

    assert_raises RuntimeError do
      NotificationService.stub(:create!, ->(**) { raise "notification failed" }) do
        PollService.invite(
          poll: poll,
          actor: @admin,
          params: { recipient_user_ids: [ @voter.id ], notify_recipients: true }
        )
      end
    end

    assert_not poll.anonymous_poll_voters.exists?(voter_id: @voter.id)
    assert_empty poll.stances
  end

  test "the model rejects anonymous stance polls" do
    legacy_poll = Poll.new(
      title: "Legacy anonymous poll",
      poll_type: "proposal",
      closing_at: 3.days.from_now,
      topic: @poll.topic,
      author: @admin,
      anonymous: true,
      poll_option_names: ["Agree", "Disagree"]
    )

    assert_not legacy_poll.valid?
    assert legacy_poll.errors.added?(:voting_system, :invalid)
  end

  test "the poll update API cannot convert identified voting to anonymous voting" do
    identified_poll = PollService.create(
      params: {
        title: "Identified poll",
        poll_type: "proposal",
        closing_at: 3.days.from_now,
        group_id: @group.id,
        poll_option_names: ["Agree", "Disagree"]
      },
      actor: @admin
    )

    refute PollService.update(poll: identified_poll, params: { anonymous: true }, actor: @admin)
    refute identified_poll.reload.anonymous?
  end

  test "automatic reminders select only voters who have not submitted" do
    AnonymousBallotService.create(anonymous_ballot: build_ballot(@poll.poll_options.first), actor: @voter)
    recipient_ids = @poll.unmasked_undecided_voters.pluck(:id)

    assert_equal "undecided_voters", @poll.notify_on_closing_soon
    assert_not_includes recipient_ids, @voter.id
    assert_includes recipient_ids, @admin.id
  end

  test "anonymous-ballot reminders use the direct notification producer" do
    notification = nil
    assert_no_difference -> { TopicItem.where(kind: "poll_closing_soon", itemable: @poll).count } do
      notification = NotificationService.create!(
        kind: "poll_closing_soon",
        subject: @poll,
        actor: @admin
      )
    end

    ResolveNotificationDeliveriesWorker.perform_now(notification.id)
    recipient_ids = notification.notification_deliveries.where(recipient_type: "User").pluck(:recipient_id)
    assert_includes recipient_ids, @admin.id
  end

  test "the delivery resolver accepts an anonymous-ballot notification" do
    notification = Notification.create!(
      actor: @admin,
      kind: "poll_closing_soon",
      subject: @poll
    )

    NotificationDeliveryResolver.for(notification).resolve!

    assert_not_nil notification.reload.deliveries_generated_at
    assert notification.notification_deliveries.exists?(recipient: @admin)
  end

  test "anonymous-ballot expiry is eventless and idempotent" do
    @poll.update_column(:closing_at, 1.hour.ago)

    assert_no_difference -> { TopicItem.where(kind: "poll_expired", itemable: @poll).count } do
      assert_difference -> { Notification.where(kind: "poll_expired").count }, 1 do
        CloseExpiredPollWorker.perform_now(@poll.id)
      end
    end

    assert_no_difference "Notification.count" do
      CloseExpiredPollWorker.perform_now(@poll.id)
    end
  end

  test "manual anonymous poll close creates no user or stance delivery identity" do
    PollService.close(poll: @poll, actor: @admin)

    assert_empty @poll.stances
    assert_not Notification.exists?(kind: "poll_closed_by_user", subject: @poll)
  end

  test "hourly reminder publishes once when a long poll enters its final 24 hours" do
    travel_to(@poll.closing_at - 24.hours - 1.minute) do
      assert_no_difference(-> { Notification.where(kind: "poll_closing_soon", subject: @poll).count }) do
        PollService.publish_closing_soon
      end
    end

    travel_to(@poll.closing_at - 24.hours + 1.minute) do
      assert_difference(-> { Notification.where(kind: "poll_closing_soon", subject: @poll).count }, 1) do
        PollService.publish_closing_soon
      end
      assert_no_difference(-> { Notification.where(kind: "poll_closing_soon", subject: @poll).count }) do
        PollService.publish_closing_soon
      end
    end
  end

  test "hourly reminder is not published for polls lasting less than 24 hours" do
    short_poll = PollService.create(
      params: {
        title: "Short detached anonymous poll",
        poll_type: "proposal",
        closing_at: 23.hours.from_now,
        group_id: @group.id,
        anonymous: true,
        poll_option_names: ["Agree", "Disagree"]
      },
      actor: @admin
    )

    assert short_poll.detached_anonymous?
    assert_no_difference(-> { Notification.where(kind: "poll_closing_soon", subject: short_poll).count }) do
      PollService.publish_closing_soon
    end
  end

  test "hourly reminder uses an extended deadline without scheduling state" do
    original_closing_at = @poll.closing_at
    @poll.update!(closing_at: original_closing_at + 2.days)

    travel_to(original_closing_at - 24.hours + 1.minute) do
      assert_no_difference(-> { Notification.where(kind: "poll_closing_soon", subject: @poll).count }) do
        PollService.publish_closing_soon
      end
    end

    travel_to(@poll.closing_at - 24.hours + 1.minute) do
      assert_difference(-> { Notification.where(kind: "poll_closing_soon", subject: @poll).count }, 1) do
        PollService.publish_closing_soon
      end
    end
  end

  test "submits a ballot without storing a voter relationship or timing metadata" do
    ballot = build_ballot(@poll.poll_options.first)
    mail_jobs_before = ActiveJob::Base.queue_adapter.enqueued_jobs.count do |job|
      job[:job] == ActionMailer::MailDeliveryJob
    end

    assert_no_difference -> { Notification.where(kind: %w[stance_created stance_updated]).count } do
      assert AnonymousBallotService.create(anonymous_ballot: ballot, actor: @voter)
    end

    ballot.reload
    mail_jobs_after = ActiveJob::Base.queue_adapter.enqueued_jobs.count do |job|
      job[:job] == ActionMailer::MailDeliveryJob
    end
    assert_match(/\A[0-9a-f-]{36}\z/, ballot.id)
    assert_equal mail_jobs_before, mail_jobs_after
    assert @poll.anonymous_poll_voters.find_by!(voter: @voter).ballot_submitted?
    assert_empty @poll.stances
    assert_empty TopicItem.where(itemable_type: "AnonymousBallot", itemable_id: ballot.id)
    assert_not ballot.attributes.key?("created_at")
    assert_not ballot.attributes.key?("updated_at")
    assert_not ballot.attributes.key?("voter_id")
    assert_not ballot.attributes.key?("anonymous_poll_voter_id")
    assert_equal %w[anonymous_ballot_id poll_option_id score], AnonymousBallotChoice.column_names.sort
  end

  test "does not allow a second ballot" do
    AnonymousBallotService.create(anonymous_ballot: build_ballot(@poll.poll_options.first), actor: @voter)

    assert_raises(CanCan::AccessDenied) do
      AnonymousBallotService.create(anonymous_ballot: build_ballot(@poll.poll_options.last), actor: @voter)
    end

    assert_equal 1, @poll.anonymous_ballots.count
  end

  test "rejects a ballot when the poll closes at the poll lock boundary" do
    ballot = build_ballot(@poll.poll_options.first)
    locked = false

    @poll.stub(:lock!, -> {
      locked = true
      @poll
    }) do
      @poll.stub(:active?, -> { !locked }) do
        assert_raises(CanCan::AccessDenied) do
          AnonymousBallotService.create(anonymous_ballot: ballot, actor: @voter)
        end
      end
    end

    assert_empty @poll.reload.anonymous_ballots
    refute @poll.anonymous_poll_voters.find_by!(voter: @voter).ballot_submitted?
  end

  test "ballots, choices, and voting configuration are immutable" do
    ballot = build_ballot(@poll.poll_options.first)
    AnonymousBallotService.create(anonymous_ballot: ballot, actor: @voter)
    choice = ballot.anonymous_ballot_choices.first

    refute ballot.update(none_of_the_above: true)
    refute ballot.destroy
    refute choice.update(score: 2)
    refute choice.destroy
    refute @poll.update(hide_results: "off")
    refute @poll.poll_options.first.update(name: "Changed")
  end

  test "database rejects a negative detached anonymous score" do
    ballot_id = SecureRandom.uuid
    AnonymousBallot.insert_all!([{
      id: ballot_id,
      poll_id: @poll.id,
      none_of_the_above: false
    }])

    assert_raises(ActiveRecord::StatementInvalid) do
      AnonymousBallotChoice.insert_all!([{
        anonymous_ballot_id: ballot_id,
        poll_option_id: @poll.poll_options.first.id,
        score: -1
      }])
    end
  end

  test "aggregate-only policy blocks ballot-pattern exports" do
    AnonymousBallotService.create(anonymous_ballot: build_ballot(@poll.poll_options.first), actor: @voter)
    PollService.close(poll: @poll, actor: @admin)

    assert_raises(CanCan::AccessDenied) { PollExporter.new(@poll).to_blt }
    assert_includes PollExporter.new(@poll).to_csv, "poll_options"
    assert_not_includes PollExporter.new(@poll).to_csv, @poll.anonymous_ballots.first.id
  end

  test "specified electorate invitations create no stances and remain open after the first ballot" do
    poll = PollService.create(
      params: {
        title: "Specified anonymous poll",
        poll_type: "proposal",
        closing_at: 3.days.from_now,
        group_id: @group.id,
        anonymous: true,
        specified_voters_only: true,
        poll_option_names: ["Agree", "Disagree"]
      },
      actor: @admin
    )

    voters = PollService.invite(
      poll: poll,
      actor: @admin,
      params: { recipient_user_ids: [@voter.id], notify_recipients: true }
    )

    assert_equal [@voter.id], voters.pluck(:voter_id)
    assert_equal 1, poll.reload.voters_count
    assert_equal 1, poll.undecided_voters_count
    assert_empty poll.stances
    notification = Notification.about(poll).find_by!(kind: "poll_announced")
    assert_equal [ @voter.id ], notification.recipient_user_ids
    assert_no_difference -> { TopicItem.where(kind: "poll_announced", itemable: poll).count } do
      ResolveNotificationDeliveriesWorker.perform_now(notification.id)
    end

    AnonymousBallotService.create(
      anonymous_ballot: poll.anonymous_ballots.build(
        anonymous_ballot_choices_attributes: [{ poll_option_id: poll.poll_options.first.id }]
      ),
      actor: @voter
    )

    late_voter = users(:alien)
    voters = PollService.invite(
      poll: poll,
      actor: @admin,
      params: { recipient_emails: [late_voter.email] }
    )

    assert_equal [late_voter.id], voters.pluck(:voter_id)
    assert_not poll.anonymous_poll_voters.find_by!(voter: late_voter).group_member
    assert_equal 2, poll.reload.voters_count
    assert_equal 1, poll.undecided_voters_count
    assert_equal 1, poll.anonymous_ballots.count
  end

  test "late specified electorate invitations take the shared poll lock" do
    poll = PollService.create(
      params: {
        title: "Specified anonymous poll",
        poll_type: "proposal",
        closing_at: 3.days.from_now,
        group_id: @group.id,
        anonymous: true,
        specified_voters_only: true,
        poll_option_names: ["Agree", "Disagree"]
      },
      actor: @admin
    )
    PollService.invite(
      poll: poll,
      actor: @admin,
      params: { recipient_user_ids: [@voter.id] }
    )
    AnonymousBallotService.create(
      anonymous_ballot: poll.anonymous_ballots.build(
        anonymous_ballot_choices_attributes: [{ poll_option_id: poll.poll_options.first.id }]
      ),
      actor: @voter
    )
    locked = false

    poll.stub(:lock!, -> {
      locked = true
      poll
    }) do
      PollService.invite(
        poll: poll,
        actor: @admin,
        params: { recipient_emails: [users(:alien).email] }
      )
    end

    assert locked
    assert poll.anonymous_poll_voters.exists?(voter_id: users(:alien).id)
  end

  test "specified electorate invitations are rejected after an anonymous poll closes" do
    poll = PollService.create(
      params: {
        title: "Specified anonymous poll",
        poll_type: "proposal",
        closing_at: 3.days.from_now,
        group_id: @group.id,
        anonymous: true,
        specified_voters_only: true,
        poll_option_names: ["Agree", "Disagree"]
      },
      actor: @admin
    )
    PollService.close(poll: poll, actor: @admin)

    assert_raises(CanCan::AccessDenied) do
      PollService.invite(
        poll: poll,
        actor: @admin,
        params: { recipient_emails: [users(:alien).email] }
      )
    end

    refute poll.anonymous_poll_voters.exists?(voter_id: users(:alien).id)
  end

  test "closing takes the shared poll lock" do
    lock_called = false

    @poll.stub(:lock!, -> {
      lock_called = true
      @poll
    }) do
      PollService.do_closing_work(poll: @poll)
    end

    assert lock_called
    assert @poll.reload.closed?
  end

  test "direct-topic voters use the detached path without group metadata" do
    topic = discussions(:discussion).topic
    topic.update!(group_id: nil)
    TopicReader.for(user: @admin, topic: topic).update!(admin: true, guest: true)
    poll = PollService.create(
      params: {
        title: "Direct anonymous poll",
        poll_type: "proposal",
        closing_at: 3.days.from_now,
        topic_id: topic.id,
        anonymous: true,
        specified_voters_only: true,
        poll_option_names: ["Agree", "Disagree"]
      },
      actor: @admin
    )
    PollService.invite(
      poll: poll,
      actor: @admin,
      params: { recipient_user_ids: [@voter.id] }
    )

    voter = poll.anonymous_poll_voters.find_by!(voter: @voter)
    refute voter.group_member?
    AnonymousBallotService.create(
      anonymous_ballot: poll.anonymous_ballots.build(
        anonymous_ballot_choices_attributes: [{ poll_option_id: poll.poll_options.first.id }]
      ),
      actor: @voter
    )
    assert voter.reload.ballot_submitted?
    assert_empty poll.stances
  end

  test "rejects a choice belonging to another poll" do
    other_poll = PollService.create(
      params: {
        title: "Other poll",
        poll_type: "proposal",
        closing_at: 3.days.from_now,
        group_id: @group.id,
        poll_option_names: ["Agree", "Disagree"]
      },
      actor: @admin
    )

    assert_raises(ActiveRecord::RecordInvalid) do
      AnonymousBallotService.create(
        anonymous_ballot: build_ballot(other_poll.poll_options.first),
        actor: @voter
      )
    end

    refute @poll.anonymous_poll_voters.find_by!(voter: @voter).ballot_submitted?
    assert_empty @poll.reload.anonymous_ballots
  end

  test "rejects duplicate choices before the database constraint is reached" do
    option = @poll.poll_options.first
    ballot = @poll.anonymous_ballots.build(
      anonymous_ballot_choices_attributes: [
        { poll_option_id: option.id, score: 1 },
        { poll_option_id: option.id, score: 1 }
      ]
    )

    assert_raises(ActiveRecord::RecordInvalid) do
      AnonymousBallotService.create(anonymous_ballot: ballot, actor: @voter)
    end

    refute @poll.anonymous_poll_voters.find_by!(voter: @voter).ballot_submitted?
    assert_empty @poll.reload.anonymous_ballots
  end

  test "rejects malformed fixed-score ballots without consuming the vote" do
    ballot = @poll.anonymous_ballots.build(
      anonymous_ballot_choices_attributes: @poll.poll_options.map do |option|
        { poll_option_id: option.id, score: option == @poll.poll_options.first ? 1 : -1 }
      end
    )

    assert_raises(ActiveRecord::RecordInvalid) do
      AnonymousBallotService.create(anonymous_ballot: ballot, actor: @voter)
    end

    refute @poll.anonymous_poll_voters.find_by!(voter: @voter).ballot_submitted?
    assert_empty @poll.reload.anonymous_ballots
  end

  test "rejects malformed anonymous ranked ballots" do
    poll = PollService.create(
      params: {
        title: "Anonymous ranked poll",
        poll_type: "ranked_choice",
        closing_at: 3.days.from_now,
        group_id: @group.id,
        anonymous: true,
        minimum_stance_choices: 3,
        poll_option_names: %w[Apple Orange Banana]
      },
      actor: @admin
    )
    ballot = poll.anonymous_ballots.build(
      anonymous_ballot_choices_attributes: poll.poll_options.zip([9999, 2, 1]).map do |option, score|
        { poll_option_id: option.id, score: score }
      end
    )

    assert_raises(ActiveRecord::RecordInvalid) do
      AnonymousBallotService.create(anonymous_ballot: ballot, actor: @voter)
    end

    refute poll.anonymous_poll_voters.find_by!(voter: @voter).ballot_submitted?
    assert_empty poll.reload.anonymous_ballots
  end

  test "results remain hidden before close and use detached choices after close" do
    AnonymousBallotService.create(anonymous_ballot: build_ballot(@poll.poll_options.first), actor: @voter)
    @poll.reload

    open_serializer = PollSerializer.new(@poll, scope: { current_user_id: @admin.id })
    refute open_serializer.send(:include_results?)
    refute open_serializer.send(:include_stance_counts?)
    refute open_serializer.send(:include_decided_voters_count?)
    refute open_serializer.send(:include_undecided_voters_count?)
    refute open_serializer.send(:include_cast_stances_pct?)

    PollService.close(poll: @poll, actor: @admin)
    closed_serializer = PollSerializer.new(@poll.reload, scope: { current_user_id: @admin.id })
    assert closed_serializer.send(:include_results?)
    agree_result = closed_serializer.results.find { |result| result[:id] == @poll.poll_options.first.id }

    assert_equal 1, agree_result[:score]
    assert_equal({}, agree_result[:voter_scores])
    assert_empty agree_result[:voter_ids]
  end

  test "the electorate and ballot have no joinable application-visible value" do
    ballot = build_ballot(@poll.poll_options.first)
    AnonymousBallotService.create(anonymous_ballot: ballot, actor: @voter)
    voter = @poll.anonymous_poll_voters.find_by!(voter: @voter)

    ballot_values = ballot.reload.attributes.values.compact.map(&:to_s)
    voter_values = voter.attributes.except("poll_id", "id", "ballot_submitted", "group_member").values.compact.map(&:to_s)

    assert_empty ballot_values & voter_values
  end

  private

  def build_ballot(option)
    @poll.anonymous_ballots.build(
      anonymous_ballot_choices_attributes: [{ poll_option_id: option.id, score: 1 }]
    )
  end
end
