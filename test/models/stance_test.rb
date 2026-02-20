require 'test_helper'

class StanceTest < ActiveSupport::TestCase
  setup do
    @user = users(:group_admin)
    @group = groups(:test_group)
  end

  test "allows no stance choices for polls" do
    poll = Poll.create!(
      poll_type: 'poll',
      title: 'Test poll',
      poll_option_names: %w[Yes No],
      closing_at: 1.day.from_now,
      author: @user,
      group: @group
    )
    stance = Stance.new(poll: poll, participant: @user)
    assert stance.valid?
  end

  test "requires a stance choice for proposals" do
    proposal = Poll.create!(
      poll_type: 'proposal',
      title: 'Test proposal',
      poll_option_names: %w[Agree Disagree Abstain],
      closing_at: 1.day.from_now,
      author: @user,
      group: @group
    )
    stance = Stance.new(poll: proposal, participant: @user, cast_at: Time.zone.now)
    assert_not stance.valid?
  end

  test "requires a certain number of stance choices for ranked choice" do
    ranked = Poll.create!(
      poll_type: 'ranked_choice',
      title: 'Test ranked',
      poll_option_names: %w[apple orange banana],
      closing_at: 1.day.from_now,
      author: @user,
      group: @group
    )
    stance = Stance.new(poll: ranked, participant: @user, choice: ['apple'])
    assert_not stance.valid?
  end

  test "reason has a length validation" do
    poll = Poll.create!(
      poll_type: 'poll',
      title: 'Test poll',
      poll_option_names: %w[Yes No],
      closing_at: 1.day.from_now,
      author: @user,
      group: @group
    )
    stance = Stance.new(poll: poll, participant: @user, reason: "a" * 505, cast_at: Time.zone.now)
    assert_not stance.valid?
  end

  test "choice shorthand with string" do
    poll = Poll.create!(
      poll_type: 'poll',
      maximum_stance_choices: 2,
      title: 'which pet?',
      poll_option_names: %w[dog cat],
      closing_at: 1.day.from_now,
      author: @user,
      group: @group
    )
    Stance.create!(poll: poll, participant: @user, choice: 'dog')
    poll.update_counts!
    assert_equal [1, 0], poll.stance_counts
  end

  test "choice shorthand with array" do
    poll = Poll.create!(
      poll_type: 'poll',
      maximum_stance_choices: 2,
      title: 'which pet?',
      poll_option_names: %w[dog cat],
      closing_at: 1.day.from_now,
      author: @user,
      group: @group
    )
    Stance.create!(poll: poll, participant: @user, choice: ['dog', 'cat'])
    poll.update_counts!
    assert_equal [1, 1], poll.stance_counts
  end
end
