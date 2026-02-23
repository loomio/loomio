require 'test_helper'

class StanceTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @group = groups(:group)
  end

  def poll_params(**overrides)
    {
      poll_type: 'poll',
      title: 'Test poll',
      poll_option_names: %w[Yes No],
      closing_at: 1.day.from_now,
      notify_on_open: false
    }.merge(overrides)
  end

  test "allows no stance choices for polls" do
    poll = PollService.create(params: poll_params, actor: @admin)
    stance = Stance.new(poll: poll, participant: @admin)
    assert stance.valid?
  end

  test "requires a stance choice for proposals" do
    poll = PollService.create(params: poll_params(
      poll_type: 'proposal',
      title: 'Test proposal',
      poll_option_names: %w[agree disagree abstain]
    ), actor: @admin)
    stance = Stance.new(poll: poll, participant: @admin, cast_at: Time.zone.now)
    assert_not stance.valid?
  end

  test "requires a certain number of stance choices for ranked choice" do
    poll = PollService.create(params: poll_params(
      poll_type: 'ranked_choice',
      title: 'Test ranked',
      poll_option_names: %w[apple orange banana]
    ), actor: @admin)
    stance = Stance.new(poll: poll, participant: @admin, choice: ['apple'])
    assert_not stance.valid?
  end

  test "reason has a length validation" do
    poll = PollService.create(params: poll_params, actor: @admin)
    stance = Stance.new(poll: poll, participant: @admin, reason: "a" * 505, cast_at: Time.zone.now)
    assert_not stance.valid?
  end

  test "choice shorthand with string" do
    poll = PollService.create(params: poll_params(
      maximum_stance_choices: 2,
      title: 'which pet?',
      poll_option_names: %w[dog cat]
    ), actor: @admin)
    Stance.create!(poll: poll, participant: @admin, choice: 'dog')
    poll.update_counts!
    assert_equal [1, 0], poll.stance_counts
  end

  test "choice shorthand with array" do
    poll = PollService.create(params: poll_params(
      maximum_stance_choices: 2,
      title: 'which pet?',
      poll_option_names: %w[dog cat]
    ), actor: @admin)
    Stance.create!(poll: poll, participant: @admin, choice: ['dog', 'cat'])
    poll.update_counts!
    assert_equal [1, 1], poll.stance_counts
  end
end
