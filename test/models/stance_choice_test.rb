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

  test "poll option must belong to the stance poll" do
    poll = PollService.create(params: poll_params, actor: @admin)
    other_poll = PollService.create(params: poll_params(title: "Other poll"), actor: @admin)
    stance = Stance.new(poll: poll, participant: @admin)
    choice = StanceChoice.new(stance: stance, poll_option: other_poll.poll_options.first, score: 1)

    error = assert_raises(RuntimeError) { choice.valid? }

    assert_equal "Stance choice poll_option must belong to the stance poll", error.message
  end

  test "nested stance validation raises for an option from another poll" do
    poll = PollService.create(params: poll_params, actor: @admin)
    other_poll = PollService.create(params: poll_params(title: "Other nested poll"), actor: @admin)
    stance = Stance.new(
      poll: poll,
      participant: @admin,
      stance_choices_attributes: [{ poll_option_id: other_poll.poll_options.first.id, score: 1 }]
    )

    assert_raises(RuntimeError) { stance.valid? }
  end

  test "stance cannot contain the same poll option twice" do
    poll = PollService.create(params: poll_params, actor: @admin)
    option = poll.poll_options.first
    stance = Stance.new(
      poll: poll,
      participant: @admin,
      stance_choices_attributes: [
        { poll_option_id: option.id, score: 1 },
        { poll_option_id: option.id, score: 1 }
      ]
    )

    error = assert_raises(RuntimeError) { stance.valid? }

    assert_equal "Stance poll options must be unique", error.message
  end

  test "database rejects the same poll option twice for one stance" do
    poll = PollService.create(params: poll_params, actor: @admin)
    stance = poll.stances.find_by!(participant: @admin)
    stance.update!(stance_choices_attributes: [{ poll_option_id: poll.poll_options.first.id, score: 1 }])

    assert_raises(ActiveRecord::RecordNotUnique) do
      StanceChoice.insert_all!([{
        stance_id: stance.id,
        poll_option_id: poll.poll_options.first.id,
        score: 1
      }])
    end
  end

  test "database rejects a missing poll option" do
    poll = PollService.create(params: poll_params, actor: @admin)
    stance = poll.stances.find_by!(participant: @admin)

    assert_raises(ActiveRecord::InvalidForeignKey) do
      StanceChoice.insert_all!([{
        stance_id: stance.id,
        poll_option_id: PollOption.maximum(:id) + 100,
        score: 1
      }])
    end
  end

  test "deleting a stance cascades to its choices" do
    poll = PollService.create(params: poll_params, actor: @admin)
    stance = poll.stances.find_by!(participant: @admin)
    stance.update!(stance_choices_attributes: [{ poll_option_id: poll.poll_options.first.id, score: 1 }])
    choice_id = stance.stance_choice_ids.first

    Stance.where(id: stance.id).delete_all

    assert_not StanceChoice.exists?(choice_id)
  end

  test "deleting a poll option cascades to its choices" do
    poll = PollService.create(params: poll_params, actor: @admin)
    option = poll.poll_options.first
    stance = poll.stances.find_by!(participant: @admin)
    stance.update!(stance_choices_attributes: [{ poll_option_id: option.id, score: 1 }])
    choice_id = stance.stance_choice_ids.first

    PollOption.where(id: option.id).delete_all

    assert_not StanceChoice.exists?(choice_id)
  end
end
