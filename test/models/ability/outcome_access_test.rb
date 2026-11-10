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

  test "outcomes can be set only on closed polls that have not been deleted" do
    admin = users(:admin)
    build = ->(**params) {
      PollService.create(params: {
        title: 'Outcome timing', poll_type: 'proposal', poll_option_names: %w[Yes No],
        closing_at: 1.day.from_now, group_id: groups(:group).id, notify_on_open: false, **params
      }, actor: admin)
    }
    outcome_on = ->(poll) { Outcome.new(poll: poll, author: admin, statement: 'Conclusion') }

    open = build.call
    assert_not admin.can?(:create, outcome_on.call(open)), 'open'

    scheduled = build.call(opening_at: 1.hour.from_now)
    assert_not admin.can?(:create, outcome_on.call(scheduled)), 'scheduled'

    lapsed = build.call
    lapsed.update_columns(closing_at: 1.minute.ago)
    assert_not admin.can?(:create, outcome_on.call(lapsed.reload)), 'lapsed before the expiry job closes it'

    closed = build.call
    PollService.close(poll: closed, actor: admin)
    assert admin.can?(:create, outcome_on.call(closed.reload)), 'closed'
    assert users(:user).can?(:create, outcome_on.call(closed)), 'members may conclude when members can edit discussions'
    assert_not users(:alien).can?(:create, outcome_on.call(closed)), 'non-members'

    PollService.discard(poll: closed, actor: admin)
    assert_not admin.can?(:create, outcome_on.call(closed.reload)), 'discarded'
  end
end
