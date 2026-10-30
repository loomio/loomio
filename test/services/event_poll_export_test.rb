require 'test_helper'
require_relative '../support/event_poll_helper'

class EventPollExportTest < ActiveSupport::TestCase
  include EventPollHelper

  test 'portable archives preserve event schedules but create fresh calendar identities and credentials' do
    poll = create_event_poll
    source = PollService.create(actor: users(:admin), params: {
      title: 'Availability source', poll_type: 'availability', topic_id: poll.topic_id,
      poll_option_names: [poll.event_starts_at.iso8601], closing_at: 1.day.from_now, notify_on_open: false
    })
    PollService.close(poll: source, actor: users(:admin))
    outcome = OutcomeService.create(actor: users(:admin), outcome: Outcome.new(poll: source,
      poll_option: source.poll_options.first, statement: 'Chosen time'))
    poll.update!(source_outcome: outcome)
    invitation = calendar_invitation(poll)
    subscription = CalendarSubscription.create!(membership: memberships(:member_normal_membership))
    filename = GroupExportService.export(poll.group.all_groups, poll.group.name)
    archive = File.read(filename)
    assert_not_includes archive, invitation.token
    assert_not_includes archive, subscription.token
    assert_not_includes archive, poll.calendar_uid
    original_time = poll.event_starts_at

    GroupExportService.import(filename, reset_keys: true)
    imported = Poll.where.not(id: poll.id).find_by!(title: poll.title)
    assert_equal original_time, imported.event_starts_at
    assert imported.calendar_uid.present?
    assert_not_equal poll.calendar_uid, imported.calendar_uid
    assert_not_equal outcome.id, imported.source_outcome_id
    assert_equal source.title, imported.source_outcome.poll.title
    assert_empty imported.calendar_invitations
  ensure
    File.delete(filename) if filename && File.exist?(filename)
  end
end
