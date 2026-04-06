require 'test_helper'

class StanceChoiceTest < ActiveSupport::TestCase
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
      group_id: @group.id,
      notify_on_open: false
    }.merge(overrides)
  end

  test "allows scores equal to 1" do
    poll = PollService.create(params: poll_params, actor: @admin)
    stance = Stance.new(poll: poll, participant: @admin)
    choice = StanceChoice.new(poll: poll, stance: stance, poll_option: poll.poll_options.first, score: 1)
    assert choice.valid?
  end

  test "allows scores greater than 1 if poll has variable score" do
    poll = PollService.create(params: poll_params(
      poll_type: 'dot_vote',
      title: 'Dot vote poll',
      poll_option_names: %w[Alpha Beta]
    ), actor: @admin)
    stance = Stance.new(poll: poll, participant: @admin)
    choice = StanceChoice.new(poll: poll, stance: stance, poll_option: poll.poll_options.first, score: 4)
    assert choice.valid?
  end

  test "does not allow scores greater than 1 if poll disallows it" do
    poll = PollService.create(params: poll_params, actor: @admin)
    stance = Stance.new(poll: poll, participant: @admin)
    choice = StanceChoice.new(poll: poll, stance: stance, poll_option: poll.poll_options.first, score: 4)
    assert_not choice.valid?
  end
end
