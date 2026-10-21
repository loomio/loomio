require 'test_helper'

class PollOptionTest < ActiveSupport::TestCase
  test "does not count old stances in total score" do
    admin = users(:admin)
    group = groups(:group)

    poll = PollService.create(params: {
      poll_type: 'dot_vote',
      title: 'Dot vote',
      poll_option_names: %w[Alpha Beta],
      closing_at: 1.day.from_now,
      group_id: group.id,
      specified_voters_only: true,
      notify_on_open: false
    }, actor: admin)
    poll_option = poll.poll_options.first

    # Create old stance (not latest)
    old_stance = Stance.create!(
      participant: admin,
      latest: false,
      poll: poll,
      stance_choices_attributes: [{ poll_option_id: poll_option.id, score: 1 }]
    )

    # Create new stance (latest)
    new_stance = Stance.create!(
      participant: admin,
      latest: true,
      poll: poll,
      stance_choices_attributes: [{ poll_option_id: poll_option.id, score: 2 }]
    )

    poll.update_counts!
    poll_option.reload
    assert_equal 2, poll_option.total_score
  end

  test "weights scores without weighting voter count or average" do
    poll = PollService.create(params: {
      poll_type: 'score',
      title: 'Weighted score',
      poll_option_names: %w[Alpha Beta],
      min_score: 0,
      max_score: 5,
      closing_at: 1.day.from_now,
      group_id: groups(:group).id,
      weighted_voting: true,
      specified_voters_only: true,
      notify_on_open: false
    }, actor: users(:admin))
    option = poll.poll_options.first

    Stance.create!(
      participant: users(:admin),
      poll: poll,
      weight: 2,
      cast_at: Time.current,
      stance_choices_attributes: [{poll_option_id: option.id, score: 4}]
    )
    Stance.create!(
      participant: users(:user),
      poll: poll,
      weight: 0,
      cast_at: Time.current,
      stance_choices_attributes: [{poll_option_id: option.id, score: 1}]
    )

    poll.update_counts!
    option.reload
    assert_equal 8, option.total_score
    assert_equal 5, poll.results.find { |result| result[:id] == option.id }[:unweighted_score]
    assert_equal 2, option.voter_count
    assert_equal 5, option.unweighted_score
    assert_equal 2, option.voter_weight_total
    assert_equal 4, option.weighted_average_score
  end

  test "weighted scores can exceed the integer column range" do
    poll = PollService.create(params: {
      poll_type: 'score',
      title: 'Large weighted score',
      poll_option_names: %w[Alpha Beta],
      min_score: 0,
      max_score: 3_000,
      closing_at: 1.day.from_now,
      group_id: groups(:group).id,
      weighted_voting: true,
      specified_voters_only: true,
      notify_on_open: false
    }, actor: users(:admin))
    option = poll.poll_options.first
    Stance.create!(
      participant: users(:admin),
      poll: poll,
      weight: 1_000_001,
      cast_at: Time.current,
      stance_choices_attributes: [{poll_option_id: option.id, score: 3_000}]
    )

    poll.update_counts!

    assert_equal 3_000_003_000, option.reload.total_score
  end

  test "fractional weights produce an exact decimal score" do
    poll = PollService.create(params: {
      poll_type: 'poll', title: 'Ownership shares', poll_option_names: %w[Yes No],
      group_id: groups(:group).id, weighted_voting: true, notify_on_open: false
    }, actor: users(:admin))
    option = poll.poll_options.find_by!(name: 'Yes')
    [ ['0.5', users(:admin)], ['2.33', users(:user)] ].each do |weight, user|
      stance = poll.stances.latest.find_by!(participant: user)
      stance.update!(weight: weight, cast_at: Time.current,
                     stance_choices_attributes: [{poll_option_id: option.id, score: 1}])
    end

    poll.update_counts!

    assert_equal BigDecimal('2.83'), option.reload.total_score
    assert_equal BigDecimal('2.83'), poll.reload.total_score
    assert_equal 2, option.voter_count
    result = poll.results.find { |row| row[:id] == option.id }
    assert_equal 2, result[:unweighted_score]
    assert_equal 2.83, result[:score]
  end

  test "anonymous result data reports its actual unweighted score" do
    poll = PollService.create(params: {
      poll_type: 'proposal', title: 'Anonymous result', poll_option_names: %w[agree disagree],
      group_id: groups(:group).id, anonymous: true, notify_on_open: false
    }, actor: users(:admin))
    option = poll.poll_options.first
    poll.anonymous_ballots.create!(anonymous_ballot_choices_attributes: [{poll_option_id: option.id, score: 1}])
    poll.update_counts!

    result = poll.results.find { |row| row[:id] == option.id }
    assert_equal 1, result[:unweighted_score]
    assert_equal 1, result[:score]
    assert_equal 1, option.reload.voter_count
    assert_equal 1, option.voter_weight_total
    assert_empty option.voter_scores
  end

  test "weighted one point polls show weighted votes without separate points" do
    poll = PollService.create(params: {
      poll_type: 'poll',
      title: 'Weighted poll',
      poll_option_names: %w[Alpha Beta],
      group_id: groups(:group).id,
      weighted_voting: true,
      notify_on_open: false
    }, actor: users(:admin))
    assert poll.weighted_voting?
    assert_includes poll.result_columns, 'voter_count'
    assert_not_includes poll.result_columns, 'unweighted_score'
    assert_includes poll.result_columns, 'score'
  end

  test "weighted score polls show points beside weighted points" do
    poll = PollService.create(params: {
      poll_type: 'score', title: 'Weighted score', poll_option_names: %w[Alpha Beta],
      group_id: groups(:group).id, weighted_voting: true, notify_on_open: false
    }, actor: users(:admin))

    assert_includes poll.result_columns, 'unweighted_score'
    assert_includes poll.result_columns, 'score'
  end

  test "STV does not apply stance weights" do
    poll = PollService.create(params: {
      poll_type: 'stv',
      title: 'Unweighted STV',
      poll_option_names: %w[Alpha Beta],
      stv_seats: 1,
      closing_at: 1.day.from_now,
      group_id: groups(:group).id,
      specified_voters_only: true,
      notify_on_open: false
    }, actor: users(:admin))
    option = poll.poll_options.first
    Stance.create!(
      participant: users(:user),
      poll: poll,
      weight: 3,
      cast_at: Time.current,
      stance_choices_attributes: [{poll_option_id: option.id, score: 1}]
    )

    poll.update_counts!

    assert_equal 1, option.reload.total_score
  end

  test "results send each voter's score only for time polls" do
    proposal = PollService.create(params: {
      poll_type: 'proposal', title: 'Scores stay out of results', poll_option_names: %w[agree disagree],
      group_id: groups(:group).id, closing_at: 1.day.from_now
    }, actor: users(:admin))
    option = proposal.poll_options.first
    proposal.stances.latest.find_by!(participant: users(:user)).update!(
      cast_at: Time.current, stance_choices_attributes: [{poll_option_id: option.id, score: 1}]
    )
    proposal.update_counts!
    result = proposal.reload.results.find { |row| row[:id] == option.id }

    assert_equal({users(:user).id.to_s => 1}, option.reload.voter_scores)
    assert_equal({}, result[:voter_scores])
    assert_equal [users(:user).id], result[:voter_ids]
  end

  test "time poll results retain zero scores and expose the complete availability grid" do
    poll = PollService.create(params: {
      poll_type: 'meeting', title: 'Availability grid', group_id: groups(:group).id,
      poll_option_names: ['2026-11-01', '2026-11-02'], notify_on_open: false
    }, actor: users(:admin))
    option = poll.poll_options.first
    {users(:user) => 0, users(:member) => 2}.each do |voter, score|
      poll.stances.latest.find_by!(participant: voter).update!(cast_at: Time.current,
        stance_choices_attributes: poll.poll_options.map { |choice| {poll_option_id: choice.id, score: choice == option ? score : 0} })
    end
    poll.update_counts!
    result = poll.reload.results.find { |row| row[:id] == option.id }

    assert_equal({users(:user).id.to_s => 0, users(:member).id.to_s => 2}, result[:voter_scores])
    assert_equal [users(:user).id, users(:member).id].sort, result[:voter_ids].sort
    assert_equal 1, option.reload.average_score
    assert_equal 0, poll.poll_options.last.average_score
  end

  test "anonymous choices freeze option changes only after a ballot exists" do
    poll = PollService.create(params: {
      poll_type: 'proposal', title: 'Frozen options', group_id: groups(:group).id,
      anonymous: true, poll_option_names: %w[agree disagree], notify_on_open: false
    }, actor: users(:admin))
    option = poll.poll_options.first
    option.update!(meaning: 'Before voting')
    poll.anonymous_ballots.create!(anonymous_ballot_choices_attributes: [{poll_option_id: option.id, score: 1}])

    assert option.reload.save
    option.meaning = 'Changed after voting'
    assert_not option.save
    assert option.errors.added?(:base, :anonymous_ballot_configuration_frozen)
    assert_equal 'Before voting', option.reload.meaning

    identified_poll = PollService.create(params: {
      poll_type: 'proposal', title: 'Editable identified options', group_id: groups(:group).id,
      poll_option_names: %w[agree disagree], notify_on_open: false
    }, actor: users(:admin))
    identified = identified_poll.poll_options.first
    assert identified.update(meaning: 'Identified options remain editable')
  end
end
