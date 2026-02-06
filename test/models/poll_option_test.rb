require 'test_helper'

class PollOptionTest < ActiveSupport::TestCase
  test "does not count old stances in total score" do
    user = User.create!(name: "PO User #{SecureRandom.hex(4)}", email: "po_#{SecureRandom.hex(4)}@test.com")
    group = Group.create!(name: "PO Group #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.add_admin!(user)

    poll = Poll.create!(
      poll_type: 'dot_vote',
      title: 'Dot vote',
      poll_option_names: %w[Alpha Beta],
      closing_at: 1.day.from_now,
      author: user,
      group: group,
      specified_voters_only: true
    )
    poll_option = poll.poll_options.first

    # Create old stance (not latest)
    old_stance = Stance.create!(
      participant: user,
      latest: false,
      poll: poll,
      stance_choices_attributes: [{ poll_option_id: poll_option.id, score: 1 }]
    )

    # Create new stance (latest)
    new_stance = Stance.create!(
      participant: user,
      latest: true,
      poll: poll,
      stance_choices_attributes: [{ poll_option_id: poll_option.id, score: 2 }]
    )

    poll.update_counts!
    poll_option.reload
    assert_equal 2, poll_option.total_score
  end
end
