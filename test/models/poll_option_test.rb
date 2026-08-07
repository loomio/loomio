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
    assert_equal 2, option.voter_count
    assert_equal 4, option.average_score
    assert_equal({users(:admin).id => 2, users(:user).id => 0}, poll.results.find { |result| result[:id] == option.id }[:voter_weights])
  end

  test "weighted polls expose both voter count and score result columns" do
    poll = PollService.create(params: {
      poll_type: 'poll',
      title: 'Weighted poll',
      poll_option_names: %w[Alpha Beta],
      group_id: groups(:group).id,
      vote_weights_enabled: true,
      notify_on_open: false
    }, actor: users(:admin))
    poll.stances.latest.first.update!(weight: 0)

    assert poll.weighted_voting?
    assert_includes poll.result_columns, 'voter_count'
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

    refute poll.vote_weights_supported?
    assert_equal 1, option.reload.total_score
  end
end
