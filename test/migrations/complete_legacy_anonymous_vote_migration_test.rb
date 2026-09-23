require "test_helper"
require Rails.root.join("db/migrate/20260819000004_complete_legacy_anonymous_vote_migration")

class CompleteLegacyAnonymousVoteMigrationTest < ActiveSupport::TestCase
  CONSTRAINT_NAME = "polls_anonymous_voting_system"

  test "direct 3.3 upgrade closes and converts an open legacy anonymous poll" do
    with_legacy_event_schema do
      poll = create_identified_poll
      stance = Stance.create!(
        poll: poll,
        participant: users(:user),
        cast_at: Time.current,
        stance_choices_attributes: [ { poll_option_id: poll.poll_options.first.id, score: 1 } ]
      )
      poll.update_counts!
      poll.update_columns(
        anonymous: true,
        hide_results: Poll.hide_results.fetch("until_closed")
      )

      CompleteLegacyAnonymousVoteMigration.new.up

      poll.reload
      assert poll.closed?
      assert_equal poll.closed_at, poll.updated_at
      assert poll.detached_anonymous?
      assert_equal 1, poll.anonymous_ballots.count
      assert_equal [ [ poll.poll_options.first.id, 1 ] ], poll.anonymous_ballot_choices.pluck(:poll_option_id, :score)
      refute Stance.exists?(stance.id)
      assert LegacyEventRecord.exists?(kind: "poll_expired", eventable: poll)
      assert_equal 0, Poll.where(anonymous: true, voting_system: :stance).count
    end
  end

  test "preserves historical option voter counts while detaching votes" do
    with_legacy_event_schema do
      poll = create_identified_poll
      stance = Stance.create!(
        poll: poll,
        participant: users(:user),
        cast_at: Time.current,
        stance_choices_attributes: [ { poll_option_id: poll.poll_options.first.id, score: 1 } ]
      )
      poll.update_counts!
      poll.update_columns(
        anonymous: true,
        closed_at: Time.current
      )
      stance.update_columns(participant_id: nil)
      poll.poll_options.update_all(voter_count: 0)
      results_before = canonical_results(poll.reload)

      CompleteLegacyAnonymousVoteMigration.new.up

      poll.reload
      assert_equal results_before, canonical_results(poll)
      assert_equal 1, poll.anonymous_ballots.count
      assert_equal 1, poll.anonymous_ballot_choices.count
      assert poll.poll_options.all? { |option| option.voter_scores.empty? }
      refute Stance.exists?(stance.id)
    end
  end

  private

  def create_identified_poll
    Poll.create!(
      title: "Legacy anonymous poll",
      poll_type: "proposal",
      closing_at: 3.days.from_now,
      opened_at: 1.day.ago,
      topic: discussions(:discussion).topic,
      author: users(:admin),
      poll_option_names: [ "Agree", "Disagree" ]
    )
  end

  def with_legacy_event_schema
    connection = ActiveRecord::Base.connection
    connection.remove_check_constraint(:polls, name: CONSTRAINT_NAME)
    connection.rename_table(:topic_items, :events)
    connection.rename_column(:events, :itemable_type, :eventable_type)
    connection.rename_column(:events, :itemable_id, :eventable_id)
    connection.rename_column(:events, :itemable_version_id, :eventable_version_id)
    connection.change_column_null(:events, :topic_id, true)
    connection.rename_table(:notifications, :notification_occurrences)
    connection.create_table(:notifications) do |t|
      t.bigint :event_id, null: false
      t.bigint :user_id, null: false
      t.bigint :actor_id
      t.jsonb :translation_values, null: false, default: {}
      t.boolean :viewed, null: false, default: false
      t.timestamps
    end
    LegacyEventRecord.reset_column_information
    LegacyNotificationRecord.reset_column_information
    yield
  ensure
    if connection.data_source_exists?(:events)
      connection.drop_table(:notifications, if_exists: true)
      connection.rename_table(:notification_occurrences, :notifications)
      connection.execute("DELETE FROM events WHERE topic_id IS NULL")
      connection.change_column_null(:events, :topic_id, false)
      connection.rename_column(:events, :eventable_type, :itemable_type)
      connection.rename_column(:events, :eventable_id, :itemable_id)
      connection.rename_column(:events, :eventable_version_id, :itemable_version_id)
      connection.rename_table(:events, :topic_items)
      TopicItem.reset_column_information
      Notification.reset_column_information
    end
  end

  def canonical_results(poll)
    PollService.calculate_results(poll, poll.poll_options.reload).map do |result|
      result.to_h.stringify_keys.slice(*LegacyAnonymousVoteMigrationService::RESULT_FIELDS)
    end.sort_by { |result| result.fetch("id") }
  end
end
