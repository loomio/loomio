require 'test_helper'

class PollQuorumTest < ActiveSupport::TestCase
  setup do
    @poll = PollService.create(params: {
      title: 'Weighted quorum', poll_type: 'proposal', poll_option_names: %w[Agree Disagree],
      weighted_voting: true, quorum_pct: 60,
      specified_voters_only: true, closing_at: 1.day.from_now, notify_on_open: false
    }, actor: users(:admin))
    @stances = [users(:admin), users(:user), users(:member)].zip(%w[0.125 0.375 0.5]).map do |voter, weight|
      Stance.create!(poll: @poll, participant: voter, weight: weight)
    end
    @poll.update_counts!
  end

  test 'weighted quorum uses issued weights and includes voters who have not voted' do
    assert_equal BigDecimal('0.6'), @poll.quorum_count
    refute @poll.quorum_reached?

    cast(@stances[0])
    cast(@stances[1])
    assert_equal 50, @poll.cast_stances_pct
    assert_equal BigDecimal('0.1'), @poll.quorum_votes_required
    refute @poll.quorum_reached?, 'two of three voters hold only half the assigned weight'

    cast(@stances[2])
    assert @poll.quorum_reached?
  end

  test 'weighted quorum accepts the exact fractional threshold without integer rounding' do
    @poll.update!(quorum_pct: 50)
    cast(@stances[2])

    assert_equal 0, @poll.quorum_votes_required
    assert @poll.quorum_reached?, 'one of three voters holds half the assigned weight'

    @stances[2].update!(weight: '0.499')
    refute @poll.quorum_reached?
    assert_equal BigDecimal('0.001'), @poll.quorum_votes_required
  end

  test 'replaced and revoked stances do not count toward the weighted electorate or participation' do
    @poll.update!(quorum_pct: 50)
    cast(@stances[2])
    @stances[0].update_columns(latest: false, weight: 100, cast_at: Time.current)
    @stances[1].update_columns(revoked_at: Time.current, weight: 100)
    @poll.update_counts!

    assert_equal BigDecimal('0.25'), @poll.quorum_count
    assert @poll.quorum_reached?
  end

  test 'none of the above participates but zero weight adds no voting power' do
    @poll.update!(show_none_of_the_above: true)
    @stances[2].update!(weight: 0)
    cast(@stances[2])
    refute @poll.quorum_reached?

    @stances[1].update!(cast_at: Time.current, none_of_the_above: true)
    @poll.update_counts!
    assert @poll.quorum_reached?
  end

  test 'a positive weighted quorum cannot be reached with no assigned voting power' do
    @stances.each { |stance| stance.update!(weight: 0) }
    @stances.each { |stance| cast(stance) }
    refute @poll.quorum_reached?

    @poll.update!(quorum_pct: 0)
    assert @poll.quorum_reached?
    @poll.update!(quorum_pct: nil)
    refute @poll.quorum_reached?
    assert_equal 0, @poll.quorum_votes_required
  end

  test 'unweighted polls count people without rounding participation percentages' do
    @poll.update!(weighted_voting: false, quorum_pct: 66)
    cast(@stances[0])
    refute @poll.quorum_reached?
    cast(@stances[1])

    assert_equal 2, @poll.quorum_count
    assert_equal 0, @poll.quorum_votes_required
    assert @poll.quorum_reached?
  end

  test 'turning off weighted voting counts people' do
    @poll.update!(weighted_voting: false)
    assert_equal 2, @poll.quorum_count
    refute @poll.quorum_reached?
  end

  test 'weighted vote share requirements use the weights of all eligible voters' do
    option = @poll.poll_options.first
    option.update!(test_operator: 'gte', test_against: 'voter_percent', test_percent: 50)
    cast(@stances[2])

    result = result_for(option)
    assert_equal 50, result[:voter_percent]
    assert_equal 100, result[:score_percent]
    assert result[:test_result], 'one of three voters holds half the assigned weight'
    assert_equal 'poll_option_form.name_gte_assigned_vote_weight', result[:test_requirement_key]

    option.update!(test_operator: 'lte', test_percent: 49)
    refute result_for(option)[:test_result]

    cast(@stances[1], @poll.poll_options.last)
    option.update!(test_operator: 'gte', test_against: 'score_percent', test_percent: 55)
    assert result_for(option)[:test_result], 'weighted support is 57 percent while plain support is 50 percent'
    option.update!(test_operator: 'lte')
    refute result_for(option)[:test_result]

    @poll.update!(weighted_voting: false)
    option.update!(test_operator: 'gte', test_against: 'voter_percent', test_percent: 50)
    result = result_for(option)
    assert_in_delta 100.0 / 3, result[:voter_percent]
    refute result[:test_result]
  end

  test 'weighted percentages include pending votes and none of the above with zero totals handled' do
    @poll.update!(show_none_of_the_above: true)
    @stances[1].update!(cast_at: Time.current, none_of_the_above: true)
    cast(@stances[0])

    assert_equal 37.5, @poll.results.find { |row| row[:id] == 0 }[:voter_percent]
    assert_equal 50, @poll.results.find { |row| row[:id] == -1 }[:voter_percent]
    assert_equal 50, @poll.cast_stances_pct

    @stances.each { |stance| stance.update!(weight: 0) }
    @poll.update_counts!
    assert @poll.results.all? { |row| row[:voter_percent] == 0 }
    assert_equal 0, @poll.cast_stances_pct
  end

  test 'anonymous polls retain headcount quorum and participation privacy thresholds' do
    @poll = PollService.create(params: {
      title: 'Anonymous quorum', poll_type: 'proposal', poll_option_names: %w[Agree Disagree],
      anonymous: true, quorum_pct: 60,
      closing_at: 1.day.from_now, notify_on_open: false
    }, actor: users(:admin))

    refute @poll.weighted_voting?
    assert_equal 3, @poll.participation_status_votes_required
  end

  private

  def result_for(option)
    @poll.reload.results.find { |row| row[:id] == option.id }
  end

  def cast(stance, option = @poll.poll_options.first)
    stance.update!(cast_at: Time.current, stance_choices_attributes: [{poll_option_id: option.id, score: 1}])
    @poll.update_counts!
  end
end
