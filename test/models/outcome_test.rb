require 'test_helper'

class OutcomeTest < ActiveSupport::TestCase
  setup do
    @user = users(:group_admin)
    @group = groups(:test_group)

    @meeting_poll = Poll.new(
      poll_type: 'meeting',
      title: 'Meeting poll',
      closing_at: 5.days.from_now,
      author: @user,
      group: @group,
      poll_option_names: ["2026-02-15"]
    )
    PollService.create(poll: @meeting_poll, actor: @user)
    @meeting_poll.update!(closed_at: 1.day.ago)
  end

  test "stores some ical text for meeting polls" do
    outcome = Outcome.create!(
      poll: @meeting_poll,
      author: @user,
      statement: "Let's meet",
      poll_option: @meeting_poll.poll_options.first
    )
    assert outcome.calendar_invite.present?
  end

  test "does nothing when no poll option is set" do
    outcome = Outcome.create!(
      poll: @meeting_poll,
      author: @user,
      statement: "Let's meet",
      poll_option: @meeting_poll.poll_options.first
    )
    outcome.update!(poll_option: nil)
    assert_nil outcome.calendar_invite
  end
end
