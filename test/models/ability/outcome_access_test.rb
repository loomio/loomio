require 'test_helper'

class Ability::OutcomeAccessTest < ActiveSupport::TestCase
  test "announcing outcomes requires closure independently of poll announcement rights" do
    %i[discussion_topic direct_topic].each do |fixture|
      coordinator = fixture == :discussion_topic ? users(:admin) : users(:guest_admin_normal)
      poll = PollService.create(params: {
        title: 'Outcome announcement boundary', poll_type: 'proposal',
        poll_option_names: %w[Yes No], closing_at: 1.day.from_now,
        topic_id: topics(fixture).id, notify_on_open: false
      }, actor: coordinator)
      outcome = Outcome.new(poll: poll, author: coordinator, statement: 'Proposed conclusion')

      assert coordinator.can?(:announce, poll)
      assert_not coordinator.can?(:announce, outcome), fixture.to_s
      PollService.close(poll: poll, actor: coordinator)
      assert coordinator.can?(:announce, outcome), fixture.to_s
      [users(:alien), users(:server_admin), LoggedOutUser.new].each do |outsider|
        assert_not outsider.can?(:announce, outcome), fixture.to_s
      end
    end
  end
end
