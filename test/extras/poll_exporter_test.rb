require 'test_helper'

class PollExporterTest < ActiveSupport::TestCase
  setup do
    @group = groups(:test_group)
    @user = users(:normal_user)
    @group.add_admin!(@user)

    @poll = Poll.new(
      title: "Board Election",
      poll_type: 'stv',
      author: @user,
      group: @group,
      closing_at: 1.day.from_now,
      stv_seats: 2,
      specified_voters_only: true
    )
    @poll.poll_option_names = %w[Alice Bob Carol]
    @poll.save!
    @poll.create_missing_created_event!

    @alice = @poll.poll_options.find_by(name: 'Alice')
    @bob   = @poll.poll_options.find_by(name: 'Bob')
    @carol = @poll.poll_options.find_by(name: 'Carol')

    # 3 voters: Alice > Bob > Carol
    3.times do
      voter = User.create!(name: "V #{SecureRandom.hex(4)}", email: "#{SecureRandom.hex(4)}@test.com")
      @group.add_member!(voter)
      stance = @poll.stances.build(participant: voter, poll: @poll)
      stance.stance_choices.build(poll_option: @alice, score: 3)
      stance.stance_choices.build(poll_option: @bob,   score: 2)
      stance.stance_choices.build(poll_option: @carol,  score: 1)
      stance.cast_at = Time.current
      stance.save!
    end

    # 2 voters: Bob > Carol
    2.times do
      voter = User.create!(name: "V #{SecureRandom.hex(4)}", email: "#{SecureRandom.hex(4)}@test.com")
      @group.add_member!(voter)
      stance = @poll.stances.build(participant: voter, poll: @poll)
      stance.stance_choices.build(poll_option: @bob,   score: 2)
      stance.stance_choices.build(poll_option: @carol,  score: 1)
      stance.cast_at = Time.current
      stance.save!
    end

    @poll.update_counts!
    @exporter = PollExporter.new(@poll)
  end

  test "to_blt produces valid BLT output" do
    blt = @exporter.to_blt
    lines = blt.strip.split("\n")

    # Header: num_candidates num_seats
    assert_equal "3 2", lines[0]

    # Ballot lines (order may vary, so collect them)
    ballot_lines = []
    i = 1
    while lines[i] != "0"
      ballot_lines << lines[i]
      i += 1
    end

    alice_idx = @poll.poll_options.order(:priority).index(@alice) + 1
    bob_idx   = @poll.poll_options.order(:priority).index(@bob) + 1
    carol_idx = @poll.poll_options.order(:priority).index(@carol) + 1

    assert_includes ballot_lines, "3 #{alice_idx} #{bob_idx} #{carol_idx} 0"
    assert_includes ballot_lines, "2 #{bob_idx} #{carol_idx} 0"

    # End-of-ballots marker
    assert_equal "0", lines[i]

    # Candidate names
    assert_equal '"Alice"', lines[i + 1]
    assert_equal '"Bob"',   lines[i + 2]
    assert_equal '"Carol"', lines[i + 3]

    # Election title
    assert_equal '"Board Election"', lines[i + 4]
  end

  test "blt_file_name includes poll details" do
    name = @exporter.blt_file_name
    assert name.start_with?("poll-#{@poll.id}-#{@poll.key}-")
    assert name.end_with?(".blt")
  end
end
