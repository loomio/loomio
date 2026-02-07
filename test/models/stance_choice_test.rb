require 'test_helper'

class StanceChoiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
    @group = groups(:test_group)
    @group.add_admin!(@user)

    # A simple poll (min_score == max_score == 1, so has_variable_score is false)
    @poll = Poll.create!(
      poll_type: 'poll',
      title: 'Test poll',
      poll_option_names: %w[Yes No],
      closing_at: 1.day.from_now,
      author: @user,
      group: @group
    )
    @stance = Stance.new(poll: @poll, participant: @user)
    @poll_option = @poll.poll_options.first
  end

  test "allows scores equal to 1" do
    choice = StanceChoice.new(poll: @poll, stance: @stance, poll_option: @poll_option, score: 1)
    assert choice.valid?
  end

  test "allows scores greater than 1 if poll has variable score" do
    # dot_vote has min_score=1, max_score=9 by default, so has_variable_score is true
    dot_vote_poll = Poll.create!(
      poll_type: 'dot_vote',
      title: 'Dot vote poll',
      poll_option_names: %w[Alpha Beta],
      closing_at: 1.day.from_now,
      author: @user,
      group: @group
    )
    stance = Stance.new(poll: dot_vote_poll, participant: @user)
    choice = StanceChoice.new(poll: dot_vote_poll, stance: stance, poll_option: dot_vote_poll.poll_options.first, score: 4)
    assert choice.valid?
  end

  test "does not allow scores greater than 1 if poll disallows it" do
    choice = StanceChoice.new(poll: @poll, stance: @stance, poll_option: @poll_option, score: 4)
    assert_not choice.valid?
  end
end
