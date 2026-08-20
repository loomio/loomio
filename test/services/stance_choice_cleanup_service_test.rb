require "test_helper"

class StanceChoiceCleanupServiceTest < ActiveSupport::TestCase
  setup do
    # The cleanup runs before these constraints are installed. Drop them inside
    # each test transaction so deliberately corrupt pre-migration rows can be
    # created; test teardown rolls every schema change back.
    connection = ActiveRecord::Base.connection
    connection.remove_foreign_key :stance_choices, column: :stance_id
    connection.remove_foreign_key :stance_choices, column: :poll_option_id
    connection.remove_foreign_key :poll_options, column: :poll_id
    connection.remove_index :stance_choices, name: "index_stance_choices_on_stance_id_and_poll_option_id"

    @admin = users(:admin)
    @poll = create_poll(title: "Cleanup poll")
    @other_poll = create_poll(title: "Other poll")
    @stance = Stance.create!(
      poll: @poll,
      participant: @admin,
      stance_choices_attributes: [{ poll_option_id: @poll.poll_options.first.id, score: 1 }]
    )
    @valid_choice = @stance.stance_choices.first
  end

  test "report describes invalid choices without deleting them" do
    missing_option_choice_id = insert_choice(poll_option_id: PollOption.maximum(:id) + 100)
    mismatched_choice_id = insert_choice(poll_option_id: @other_poll.poll_options.first.id)
    duplicate_choice_id = insert_choice(poll_option_id: @valid_choice.poll_option_id)

    report = StanceChoiceCleanupService.report

    assert_equal 1, report.dig(:counts, :missing_poll_option)
    assert_equal 1, report.dig(:counts, :poll_mismatch)
    assert_equal 1, report.dig(:counts, :duplicate_groups)
    assert_equal 3, report.dig(:counts, :invalid_choices_total)
    assert StanceChoice.exists?(missing_option_choice_id)
    assert StanceChoice.exists?(mismatched_choice_id)
    assert StanceChoice.exists?(duplicate_choice_id)
  end

  test "cleanup removes invalid choices and rebuilds affected caches" do
    missing_option_choice_id = insert_choice(poll_option_id: PollOption.maximum(:id) + 100)
    mismatched_option = @other_poll.poll_options.first
    mismatched_choice_id = insert_choice(poll_option_id: mismatched_option.id)
    duplicate_choice_id = insert_choice(poll_option_id: @valid_choice.poll_option_id)
    @stance.update_columns(option_scores: { @valid_choice.poll_option_id.to_s => 1, "invalid" => 100 })
    mismatched_option.update_columns(total_score: 100, voter_count: 100)

    result = StanceChoiceCleanupService.cleanup!

    assert_equal 3, result[:removed_choices]
    assert_not StanceChoice.exists?(missing_option_choice_id)
    assert_not StanceChoice.exists?(mismatched_choice_id)
    assert_equal 1, StanceChoice.where(id: [@valid_choice.id, duplicate_choice_id]).count
    assert_equal @stance.reload.build_option_scores, @stance.option_scores
    assert_not_equal 100, mismatched_option.reload.total_score
    assert_not_equal 100, mismatched_option.voter_count
    assert result.fetch(:remaining).values.all?(&:zero?)
  end

  test "cleanup retains the duplicate score already visible on the stance" do
    newer_choice_id = insert_choice(poll_option_id: @valid_choice.poll_option_id, score: 2)
    @stance.update_columns(option_scores: { @valid_choice.poll_option_id.to_s => 1 })

    StanceChoiceCleanupService.cleanup!

    assert StanceChoice.exists?(@valid_choice.id)
    assert_not StanceChoice.exists?(newer_choice_id)
    assert_equal({ @valid_choice.poll_option_id.to_s => 1 }, @stance.reload.option_scores)
  end

  test "cleanup repairs stale poll option aggregate caches" do
    option = @poll.poll_options.first
    option.update_columns(total_score: 100, voter_count: 100)

    report = StanceChoiceCleanupService.report
    assert_includes report.dig(:samples, :stale_poll_option_cache_ids), option.id

    result = StanceChoiceCleanupService.cleanup!

    assert_equal 1, result[:repaired_poll_option_caches]
    assert_equal 1, option.reload.total_score
    assert_equal 1, option.voter_count
    assert_equal 0, result.dig(:remaining, :stale_poll_option_caches)
  end

  test "cleanup repairs a stale voter scores cache" do
    option = @poll.poll_options.first
    option.update_columns(voter_scores: { "999999" => 1 })

    report = StanceChoiceCleanupService.report
    assert_includes report.dig(:samples, :stale_poll_option_cache_ids), option.id

    result = StanceChoiceCleanupService.cleanup!

    assert_equal 1, result[:repaired_poll_option_caches]
    assert_equal({ @admin.id.to_s => 1 }, option.reload.voter_scores)
    assert_equal 0, result.dig(:remaining, :stale_poll_option_caches)
  end

  test "cleanup removes choices with missing stances and poll options with missing polls" do
    missing_stance_choice_id = StanceChoice.insert_all!([{
      stance_id: Stance.maximum(:id) + 100,
      poll_option_id: @poll.poll_options.first.id,
      score: 1
    }]).rows.first.first
    orphan_option_id = PollOption.insert_all!([{
      poll_id: Poll.maximum(:id) + 100,
      name: "Orphan",
      priority: 0,
      total_score: 0,
      voter_count: 0
    }]).rows.first.first

    result = StanceChoiceCleanupService.cleanup!

    assert_equal 1, result[:missing_stance]
    assert_equal 1, result[:poll_options_missing_poll]
    assert_not StanceChoice.exists?(missing_stance_choice_id)
    assert_not PollOption.exists?(orphan_option_id)
    assert result.fetch(:remaining).values.all?(&:zero?)
  end

  private

  def create_poll(title:)
    PollService.create(
      params: {
        poll_type: "poll",
        title: title,
        specified_voters_only: true,
        poll_option_names: %w[Yes No],
        closing_at: 1.day.from_now,
        group_id: groups(:group).id,
        notify_on_open: false
      },
      actor: @admin
    )
  end

  def insert_choice(poll_option_id:, score: 1)
    StanceChoice.insert_all!([{
      stance_id: @stance.id,
      poll_option_id: poll_option_id,
      score: score
    }]).rows.first.first
  end
end
