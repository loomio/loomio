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

    assert_equal BigDecimal('0.5'), @poll.voter_weight_total
    assert_equal BigDecimal('0.5'), @poll.voter_weight_cast
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
    assert_equal false, @poll.quorum_reached?

    @poll.update!(quorum_pct: 0)
    assert @poll.quorum_reached?
    @poll.update!(quorum_pct: nil)
    assert_equal false, @poll.quorum_reached?
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
    assert_equal 'poll_option_form.name_gte_eligible_vote_weight', result[:test_requirement_key]

    option.update!(test_operator: 'lte', test_percent: 49)
    refute result_for(option)[:test_result]
    option.update!(test_percent: 50)
    assert_equal true, result_for(option)[:test_result]

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
    pending = @poll.results.find { |row| row[:id] == -1 }
    assert_equal 50, pending[:voter_percent]
    assert_equal 0.5, pending[:score]
    assert_nil pending[:score_percent]
    assert_equal 50, @poll.cast_stances_pct

    @stances.each { |stance| stance.update!(weight: 0) }
    @poll.update_counts!
    assert @poll.results.all? { |row| row[:voter_percent] == 0 }
    assert @poll.results.all? { |row| row[:score_percent].nil? || row[:score_percent] == 0 }
    assert_equal 0, @poll.cast_stances_pct
  end

  test 'turnout divides cast weight by a non-unit electorate and switches back to people' do
    @stances.zip(%w[1 2 3]).each { |stance, weight| stance.update!(weight: weight) }
    cast(@stances[0])

    assert_equal 6, @poll.voter_weight_total
    assert_equal 1, @poll.voter_weight_cast
    assert_equal 16, @poll.cast_stances_pct
    assert_equal BigDecimal('3.6'), @poll.quorum_count
    assert_equal BigDecimal('2.6'), @poll.quorum_votes_required

    cast(@stances[1])
    assert_equal 50, @poll.cast_stances_pct

    @poll.update!(weighted_voting: false)
    assert_equal 66, @poll.cast_stances_pct
    assert_equal 'poll_common_percent_voted.pct_participation', @poll.participation_key
    assert_equal 'poll_common_percent_voted.pct_of_eligible_voters_must_participate', @poll.quorum_requirement_key
  end

  test 'no quorum requires zero additional votes even after votes have been cast' do
    cast(@stances[2])
    @poll.update!(quorum_pct: nil)

    assert_equal 0, @poll.quorum_count
    assert_equal 0, @poll.quorum_votes_required
    assert_equal false, @poll.quorum_reached?
  end

  test 'empty electorates have numeric zero turnout and result percentages in both modes' do
    @poll.stances.destroy_all
    @poll.update_counts!

    [true, false].each do |weighted|
      @poll.update!(weighted_voting: weighted, show_none_of_the_above: true)
      assert_equal 0, @poll.cast_stances_pct
      @poll.results.each do |row|
        assert_equal 0, row[:voter_percent]
        assert_equal 0, row[:target_percent]
      end
    end
  end

  test 'weighted vote-share limits include equality and distinguish eligible from cast weight' do
    @stances.zip(%w[2 2 1]).each { |stance, weight| stance.update!(weight: weight) }
    option = @poll.poll_options.first
    cast(@stances[0], option)
    cast(@stances[1], @poll.poll_options.last)
    assert_nil result_for(option)[:test_requirement_key]
    assert_nil result_for(option)[:test_result]

    {'voter_percent' => [40, 'eligible_vote_weight'], 'score_percent' => [50, 'vote_weight_cast']}.each do |basis, (threshold, label)|
      %w[gte lte].each do |operator|
        option.update!(test_operator: operator, test_against: basis, test_percent: threshold)
        result = result_for(option)
        assert_equal true, result[:test_result], "#{operator} includes equality for #{basis}"
        assert_equal "poll_option_form.name_#{operator}_#{label}", result[:test_requirement_key]

        option.update!(test_percent: threshold + (operator == 'gte' ? 1 : -1))
        assert_equal false, result_for(option)[:test_result]
        option.update!(test_percent: threshold + (operator == 'gte' ? -1 : 1))
        assert_equal true, result_for(option)[:test_result]
      end
    end

    @poll.update!(weighted_voting: false)
    option.update!(test_operator: 'gte', test_against: 'voter_percent', test_percent: 40)
    result = result_for(option)
    assert_equal false, result[:test_result]
    assert_equal 'poll_option_form.name_gte_voter_percent', result[:test_requirement_key]
    option.update!(test_against: 'score_percent', test_percent: 50)
    result = result_for(option)
    assert_equal true, result[:test_result]
    assert_equal 'poll_option_form.name_gte_score_percent', result[:test_requirement_key]
    assert_equal 0, @poll.results.find { |row| row[:id] == -1 }[:score]
  end

  test 'remaining and none-of-the-above weight exclude replaced and revoked stances' do
    @poll.update!(show_none_of_the_above: true)
    @stances[0].update!(cast_at: Time.current, none_of_the_above: true)
    cast(@stances[1])
    [{latest: false}, {revoked_at: Time.current}].each do |attributes|
      Stance.create!(poll: @poll, participant: users(:alien), weight: 100,
                     cast_at: Time.current, none_of_the_above: true, **attributes)
      Stance.create!(poll: @poll, participant: users(:subgroup_user), weight: 100, **attributes)
    end
    @poll.update_counts!

    assert_equal 1, @poll.voter_weight_total
    assert_equal BigDecimal('0.5'), @poll.voter_weight_cast
    rows = @poll.results.index_by { |row| row[:id] }
    assert_equal 12.5, rows.fetch(0)[:voter_percent]
    assert_equal 50, rows.fetch(-1)[:voter_percent]
    assert_equal 0.5, rows.fetch(-1)[:score]
  end

  test 'anonymous polls retain headcount quorum and participation privacy thresholds' do
    @poll = PollService.create(params: {
      title: 'Anonymous quorum', poll_type: 'proposal', poll_option_names: %w[Agree Disagree],
      anonymous: true, quorum_pct: 60, specified_voters_only: true, show_none_of_the_above: true,
      closing_at: 1.day.from_now, notify_on_open: false
    }, actor: users(:admin))
    PollService.invite(poll: @poll, actor: users(:admin), params: {
      recipient_user_ids: [users(:admin).id, users(:user).id, users(:member).id], notify_recipients: false
    })

    refute @poll.weighted_voting?
    assert_equal 3, @poll.voters_count
    assert_empty @poll.stances
    assert_equal 2, @poll.quorum_count
    assert_equal 3, @poll.participation_status_votes_required
    option = @poll.poll_options.first
    ballot = @poll.anonymous_ballots.new(anonymous_ballot_choices_attributes: [{poll_option_id: option.id, score: 1}])
    AnonymousBallotService.create(anonymous_ballot: ballot, actor: users(:admin))

    assert_equal 33, @poll.cast_stances_pct
    assert_equal 1, @poll.quorum_votes_required
    assert_equal false, @poll.quorum_reached?
    rows = @poll.results.index_by { |row| row[:id] }
    assert_in_delta 100.0 / 3, rows.fetch(option.id)[:voter_percent]
    assert_in_delta 200.0 / 3, rows.fetch(-1)[:voter_percent]

    AnonymousBallotService.create(anonymous_ballot: @poll.anonymous_ballots.new(none_of_the_above: true), actor: users(:user))
    assert_equal 66, @poll.cast_stances_pct
    assert_equal 0, @poll.quorum_votes_required
    assert_equal true, @poll.quorum_reached?
    assert_in_delta 100.0 / 3, @poll.results.find { |row| row[:id] == 0 }[:voter_percent]
    refute @poll.participation_status_visible?
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
