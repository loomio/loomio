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
    groups(:group).update!(vote_weights_allowed: true)
    poll = PollService.create(params: {
      poll_type: 'score',
      title: 'Weighted score',
      poll_option_names: %w[Alpha Beta],
      min_score: 0,
      max_score: 5,
      closing_at: 1.day.from_now,
      group_id: groups(:group).id,
      vote_weights_enabled: true,
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
    assert_equal 4, option.average_score
    assert_equal({users(:admin).id => '2', users(:user).id => '0'}, poll.results.find { |result| result[:id] == option.id }[:voter_weights])
  end

  test "weighted scores can exceed the integer column range" do
    groups(:group).update!(vote_weights_allowed: true)
    poll = PollService.create(params: {
      poll_type: 'score',
      title: 'Large weighted score',
      poll_option_names: %w[Alpha Beta],
      min_score: 0,
      max_score: 3_000,
      closing_at: 1.day.from_now,
      group_id: groups(:group).id,
      vote_weights_enabled: true,
      specified_voters_only: true,
      notify_on_open: false
    }, actor: users(:admin))
    option = poll.poll_options.first
    Stance.create!(
      participant: users(:admin),
      poll: poll,
      weight: 1_000_000,
      cast_at: Time.current,
      stance_choices_attributes: [{poll_option_id: option.id, score: 3_000}]
    )

    poll.update_counts!

    assert_equal 3_000_000_000, option.reload.total_score
  end

  test "fractional weights produce an exact decimal score" do
    groups(:group).update!(vote_weights_allowed: true)
    poll = PollService.create(params: {
      poll_type: 'poll', title: 'Ownership shares', poll_option_names: %w[Yes No],
      group_id: groups(:group).id, vote_weights_enabled: true, notify_on_open: false
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
    assert_equal '2.83', result[:score]
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
    assert_equal 1.0, result[:score]
  end

  test "weighted one point polls show voters and score without a duplicate score" do
    groups(:group).update!(vote_weights_allowed: true)
    poll = PollService.create(params: {
      poll_type: 'poll',
      title: 'Weighted poll',
      poll_option_names: %w[Alpha Beta],
      group_id: groups(:group).id,
      vote_weights_enabled: true,
      notify_on_open: false
    }, actor: users(:admin))
    assert poll.weighted_voting?
    assert_includes poll.result_columns, 'voter_count'
    assert_not_includes poll.result_columns, 'unweighted_score'
    assert_includes poll.result_columns, 'score'
  end

  test "weighted score polls retain the separate equal vote score" do
    groups(:group).update!(vote_weights_allowed: true)
    poll = PollService.create(params: {
      poll_type: 'score', title: 'Weighted score', poll_option_names: %w[Alpha Beta],
      group_id: groups(:group).id, vote_weights_enabled: true, notify_on_open: false
    }, actor: users(:admin))

    assert_includes poll.result_columns, 'unweighted_score'
    assert_includes poll.result_columns, 'score'
  end

  test "weighted proposals show voters and score without a duplicate equal weight score" do
    groups(:group).update!(vote_weights_allowed: true)
    poll = PollService.create(params: {
      poll_type: 'proposal',
      title: 'Weighted proposal',
      poll_option_names: %w[agree disagree],
      group_id: groups(:group).id,
      vote_weights_enabled: true,
      notify_on_open: false
    }, actor: users(:admin))

    assert_includes poll.result_columns, 'votes'
    assert_includes poll.result_columns, 'score'
    assert_not_includes poll.result_columns, 'unweighted_score'
    assert_equal poll.result_columns.index('votes') + 1, poll.result_columns.index('score')
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

    refute poll.vote_weights_supported?
    assert_equal 1, option.reload.total_score
  end
end
