require "test_helper"

class PollMarkdownResultsServiceTest < ActiveSupport::TestCase
  SIMPLE_COLUMNS = {
    "proposal" => %w[chart name votes votes_cast_percent voter_percent voters],
    "check" => %w[chart name voter_percent voter_count voters],
    "count" => %w[chart name target_percent voter_count voters],
    "poll" => %w[chart name score_percent voter_count voters],
    "score" => %w[chart name score average voter_count],
    "dot_vote" => %w[chart name score_percent score average voter_count],
    "ranked_choice" => %w[chart name rank score_percent score average voter_count]
  }.freeze

  setup do
    @user = users(:admin)
  end

  test "renders canonical columns for every simple poll type" do
    SIMPLE_COLUMNS.each do |poll_type, columns|
      poll = OpenStruct.new(
        poll_type: poll_type,
        result_columns: columns,
        anonymous?: false,
        has_variable_score: %w[score dot_vote ranked_choice].include?(poll_type),
        results: [{
          id: 1,
          name: "Option A",
          name_format: nil,
          rank: 1,
          score: 4,
          score_percent: 80,
          voter_percent: 50,
          target_percent: 75,
          average: 4.0,
          voter_count: 0
        }]
      )

      markdown = PollMarkdownResultsService.render(poll: poll, user: @user)

      assert markdown.start_with?("| "), poll_type
      assert_includes markdown, "Option A", poll_type
      assert_includes markdown, "Voters", poll_type
      refute_includes markdown, "Translation missing", poll_type
    end
  end

  test "renders a time poll availability matrix" do
    options = [OpenStruct.new(id: 1, name: "2026-10-01T09:00:00Z", total_score: 0)]
    poll = OpenStruct.new(poll_type: "meeting", time_zone: "UTC", poll_options: options, poll_option_name_format: nil)
    service = PollMarkdownResultsService.new(poll, @user)

    service.stub(:voter_stances, []) do
      markdown = service.render

      assert_includes markdown, "| UTC | Votes |"
      assert_includes markdown, "| 2026-10-01T09:00:00Z | 0 |"
    end
  end

  test "renders STV elected, tied, round, and quota tables" do
    candidates = [OpenStruct.new(id: 1, name: "A"), OpenStruct.new(id: 2, name: "B")]
    results = {
      "elected" => [{"poll_option_id" => 1, "name" => "A", "round_elected" => 1}],
      "tied" => [{"poll_option_id" => 2, "name" => "B"}],
      "rounds" => [{"round" => 1, "tallies" => {"1" => 3.0, "2" => 1.0}, "elected" => [1], "eliminated" => [], "tied" => [2]}],
      "quota" => 2.0,
      "method" => "scottish",
      "quota_type" => "droop"
    }
    poll = OpenStruct.new(poll_type: "stv", stv_results: results, poll_options: candidates)

    markdown = PollMarkdownResultsService.render(poll: poll, user: @user)

    assert_includes markdown, "#### Elected"
    assert_includes markdown, "#### Tie"
    assert_includes markdown, "| Candidate | Round elected | First preferences | Final tally | Surplus |"
    assert_includes markdown, "| Candidate | 1 |"
    assert_includes markdown, "3 ✓"
    assert_includes markdown, "Droop"
  end
end
