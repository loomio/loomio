require "test_helper"
require Rails.root.join("db/migrate/20260819000004_complete_legacy_anonymous_vote_migration")

class CompleteLegacyAnonymousVoteMigrationTest < ActiveSupport::TestCase
  CONSTRAINT_NAME = "polls_anonymous_voting_system"

  test "direct 3.3 upgrade closes and converts an open legacy anonymous poll" do
    without_anonymous_storage_constraint do
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
      assert Event.exists?(kind: "poll_expired", eventable: poll)
      assert_equal 0, Poll.where(anonymous: true, voting_system: :stance).count
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

  def without_anonymous_storage_constraint
    connection = ActiveRecord::Base.connection
    connection.remove_check_constraint(:polls, name: CONSTRAINT_NAME)
    yield
  end
end
