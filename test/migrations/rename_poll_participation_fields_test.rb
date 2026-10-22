require 'test_helper'
require Rails.root.join('db/migrate/20261023000001_rename_poll_participation_fields')

class RenamePollParticipationFieldsTest < ActiveSupport::TestCase
  test 'migration preserves counters and recipient snapshots through a round trip' do
    poll = PollService.create(params: {
      title: 'Participation migration', poll_type: 'poll', group_id: groups(:group).id,
      poll_option_names: %w[Yes No], closing_at: 1.day.from_now
    }, actor: users(:admin))
    counters = {voters_eligible_count: 7, votes_uncast_count: 3, option_score_totals: [2.5, 1]}
    poll.update_columns(counters)
    notification = Notification.create!(kind: 'poll_announced', subject: poll, actor: users(:admin),
      recipient_audience: 'voters_cast', recipient_user_ids: [users(:member).id])
    template = DiscussionTemplate.create!(title: 'Uncast audience', author: users(:admin), group: groups(:group),
      process_name: 'Discussion', process_subtitle: 'Share ideas', recipient_audience: 'voters_uncast')
    connection = ActiveRecord::Base.connection
    connection.execute('SET CONSTRAINTS ALL IMMEDIATE')

    migration = RenamePollParticipationFields.new
    migration.suppress_messages { migration.down }
    legacy = connection.select_one("SELECT voters_count, undecided_voters_count, stance_counts FROM polls WHERE id = #{poll.id}")
    assert_equal 7, legacy['voters_count']
    assert_equal 3, legacy['undecided_voters_count']
    assert_equal [2.5, 1], JSON.parse(legacy['stance_counts'])
    assert_equal 'decided_voters', notification.reload.recipient_audience
    assert_equal 'undecided_voters', template.reload.recipient_audience
    assert_equal [users(:member).id], notification.recipient_user_ids

    migration.suppress_messages { migration.up }
    assert_equal counters.stringify_keys, poll.reload.attributes.slice(*counters.keys.map(&:to_s))
    assert_equal 'voters_cast', notification.reload.recipient_audience
    assert_equal 'voters_uncast', template.reload.recipient_audience
    assert_equal [users(:member).id], notification.recipient_user_ids
  end
end
