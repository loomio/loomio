require "test_helper"
require Rails.root.join("db/migrate/20260825000001_backfill_poll_ballot_configuration")

class BackfillPollBallotConfigurationTest < ActiveSupport::TestCase
  test "backfills ballot columns without rewriting legacy JSON" do
    poll = create_test_poll
    poll.update_columns(
      min_score: nil,
      max_score: nil,
      dots_per_person: nil,
      minimum_stance_choices: nil,
      maximum_stance_choices: nil,
      custom_fields: {
        "min_score" => "-2",
        "max_score" => 9,
        "dots_per_person" => "+4",
        "minimum_stance_choices" => " 1 ",
        "maximum_stance_choices" => 2,
        "unrelated" => true
      }
    )

    BackfillPollBallotConfiguration.new.migrate(:up)

    poll.reload
    assert_equal(-2, poll[:min_score])
    assert_equal 9, poll[:max_score]
    assert_equal 4, poll[:dots_per_person]
    assert_equal 1, poll[:minimum_stance_choices]
    assert_equal 2, poll[:maximum_stance_choices]
    assert_equal "-2", poll.custom_fields["min_score"]
    assert_equal 9, poll.custom_fields["max_score"]
    assert_equal "+4", poll.custom_fields["dots_per_person"]
    assert_equal " 1 ", poll.custom_fields["minimum_stance_choices"]
    assert_equal 2, poll.custom_fields["maximum_stance_choices"]
    assert_equal true, poll.custom_fields["unrelated"]
  end

  test "keeps authoritative columns without rewriting stale or blank JSON values" do
    poll = create_test_poll
    poll.update_columns(
      min_score: nil,
      max_score: 5,
      custom_fields: poll.custom_fields.merge(
        "min_score" => "",
        "max_score" => "not an integer"
      )
    )

    BackfillPollBallotConfiguration.new.migrate(:up)

    poll.reload
    assert_nil poll[:min_score]
    assert_equal 5, poll[:max_score]
    assert_equal "", poll.custom_fields["min_score"]
    assert_equal "not an integer", poll.custom_fields["max_score"]
  end

  test "refuses to discard malformed or out-of-range values without a column value" do
    malformed = create_test_poll(title: "Malformed configuration")
    malformed.update_columns(min_score: nil, custom_fields: malformed.custom_fields.merge("min_score" => "1.5"))
    out_of_range = create_test_poll(title: "Out-of-range configuration")
    out_of_range.update_columns(max_score: nil, custom_fields: out_of_range.custom_fields.merge("max_score" => "2147483648"))

    error = assert_raises(ActiveRecord::MigrationError) do
      BackfillPollBallotConfiguration.new.migrate(:up)
    end

    assert_includes error.message, "poll #{malformed.id} min_score"
    assert_includes error.message, "poll #{out_of_range.id} max_score"
    assert_equal "1.5", malformed.reload.custom_fields["min_score"]
    assert_equal "2147483648", out_of_range.reload.custom_fields["max_score"]
  end

  test "migration is irreversible" do
    assert_raises ActiveRecord::IrreversibleMigration do
      BackfillPollBallotConfiguration.new.migrate(:down)
    end
  end

  private

  def create_test_poll(title: "Legacy ballot configuration")
    PollService.create(
      params: {
        title: title,
        poll_type: "score",
        poll_option_names: %w[apple orange],
        closing_at: 3.days.from_now
      },
      actor: users(:admin)
    )
  end
end
