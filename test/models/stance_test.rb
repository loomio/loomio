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

  test "reason length validation counts like javascript string length" do
    poll = PollService.create(params: poll_params, actor: @admin)
    stance = Stance.new(poll: poll, participant: @admin, reason: "😄" * 251, cast_at: Time.zone.now)
    assert_not stance.valid?
  end

  test "requires a reason for disagree and block options when configured" do
    poll = PollService.create(params: poll_params(
      poll_type: "proposal",
      poll_option_names: %w[agree abstain disagree block],
      stance_reason_required: "required_for_disagree_or_block"
    ), actor: @admin)

    %w[agree abstain].each do |icon|
      assert stance_for(poll, icon: icon).valid?, "expected #{icon} without a reason to be valid"
    end

    %w[disagree block].each do |icon|
      stance = stance_for(poll, icon: icon)
      assert_not stance.valid?, "expected #{icon} without a reason to be invalid"
      assert stance_for(poll, icon: icon, reason: "Because this concerns me").valid?
    end
  end

  test "requires a reason only for block options when configured" do
    poll = PollService.create(params: poll_params(
      poll_type: "proposal",
      poll_option_names: %w[agree abstain disagree block],
      stance_reason_required: "required_for_block"
    ), actor: @admin)

    %w[agree abstain disagree].each do |icon|
      assert stance_for(poll, icon: icon).valid?, "expected #{icon} without a reason to be valid"
    end

    stance = stance_for(poll, icon: "block")
    assert_not stance.valid?
    assert stance_for(poll, icon: "block", reason: "Because this concerns me").valid?
  end

  test "uses the option icon when deciding whether a reason is required" do
    poll = PollService.create(params: poll_params(
      poll_type: "proposal",
      poll_option_names: %w[agree disagree],
      stance_reason_required: "required_for_disagree_or_block"
    ), actor: @admin)
    objection = poll.poll_options.find_by!(icon: "disagree")
    objection.update!(name: "Objection")

    assert_not stance_for(poll, icon: "disagree").valid?
  end

  test "preserves the existing reason requirement modes" do
    poll = PollService.create(params: poll_params(
      poll_type: "proposal",
      poll_option_names: %w[agree disagree]
    ), actor: @admin)

    poll.stance_reason_required = "optional"
    assert stance_for(poll, icon: "disagree").valid?

    poll.stance_reason_required = "required"
    assert_not stance_for(poll, icon: "agree").valid?

    poll.stance_reason_required = "disabled"
    assert stance_for(poll, icon: "disagree").valid?
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

  private

  def stance_for(poll, icon:, reason: nil)
    Stance.new(
      poll: poll,
      participant: @admin,
      reason: reason,
      cast_at: Time.zone.now,
      stance_choices_attributes: [{poll_option_id: poll.poll_options.find_by!(icon: icon).id, score: 1}]
    )
  end
end
