require 'test_helper'
require 'csv'

class PollExporterTest < ActiveSupport::TestCase
  setup do
    @group = groups(:group)
    @admin = users(:admin)

    @poll = PollService.create(
      params: {
        title: "Board Election",
        poll_type: 'stv',
        group_id: @group.id,
        closing_at: 1.day.from_now,
        stv_seats: 2,
        specified_voters_only: true,
        poll_option_names: %w[Alice Bob Carol]
      },
      actor: @admin)

    @alice = @poll.poll_options.find_by(name: 'Alice')
    @bob   = @poll.poll_options.find_by(name: 'Bob')
    @carol = @poll.poll_options.find_by(name: 'Carol')

    # 3 voters: Alice > Bob > Carol (score = rank placement, 1 = first choice)
    3.times do
      voter = User.create!(name: "V #{SecureRandom.hex(4)}", email: "#{SecureRandom.hex(4)}@test.com")
      @group.add_member!(voter)
      stance = @poll.stances.build(participant: voter, poll: @poll)
      stance.stance_choices.build(poll_option: @alice, score: 1)
      stance.stance_choices.build(poll_option: @bob,   score: 2)
      stance.stance_choices.build(poll_option: @carol,  score: 3)
      stance.cast_at = Time.current
      stance.save!
    end

    # 2 voters: Bob > Carol
    2.times do
      voter = User.create!(name: "V #{SecureRandom.hex(4)}", email: "#{SecureRandom.hex(4)}@test.com")
      @group.add_member!(voter)
      stance = @poll.stances.build(participant: voter, poll: @poll)
      stance.stance_choices.build(poll_option: @bob,   score: 1)
      stance.stance_choices.build(poll_option: @carol,  score: 2)
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

  test "to_csv includes member title and delegate status for vote rows" do
    stance = @poll.stances.latest.first
    membership = @group.membership_for(stance.participant)
    membership.update!(title: 'Board chair', delegate: true)

    rows = CSV.parse(@exporter.to_csv)
    votes_index = rows.index(['votes'])
    headers = rows[votes_index + 1]
    vote_rows = rows[(votes_index + 2)..]
    vote_row = vote_rows.find { |row| row[headers.index('voter_id')] == stance.participant_id.to_s }

    assert_equal 'member_title', headers[4]
    assert_equal 'delegate', headers[5]
    assert_equal 'Board chair', vote_row[headers.index('member_title')]
    assert_equal 'true', vote_row[headers.index('delegate')]
  end

  test "to_csv does not use member titles or delegate status from another group" do
    stance = @poll.stances.latest.first
    membership = @group.membership_for(stance.participant)
    membership.update!(title: nil, delegate: false)

    other_group = Group.create!(name: 'Other Group', handle: 'poll-export-other-group')
    other_group.add_member!(stance.participant).update!(title: 'Other chair', delegate: true)

    rows = CSV.parse(@exporter.to_csv)
    votes_index = rows.index(['votes'])
    headers = rows[votes_index + 1]
    vote_rows = rows[(votes_index + 2)..]
    vote_row = vote_rows.find { |row| row[headers.index('voter_id')] == stance.participant_id.to_s }

    assert_nil vote_row[headers.index('member_title')]
    assert_equal 'false', vote_row[headers.index('delegate')]
  end

  test "blt_file_name includes poll details" do
    name = @exporter.blt_file_name
    assert name.start_with?("poll-#{@poll.id}-#{@poll.key}-")
    assert name.end_with?(".blt")
  end
end
