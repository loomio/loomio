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
end
