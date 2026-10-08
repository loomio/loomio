require 'test_helper'
require_relative '../../db/migrate/20261009000000_rebuild_retained_record_counts'

class RebuildRetainedRecordCountsTest < ActiveSupport::TestCase
  test 'rebuild corrects retained counts and zeroes without changing content or timestamps' do
    group = groups(:group)
    topic = topics(:discussion_topic)
    user = users(:user)
    item = topic_items(:discussion_created_topic_item)
    discussion = topic.topicable
    comment = comments(:public_discussion_comment)
    outcome = Outcome.create!(poll: polls(:trial_cleanup_poll), author: users(:admin), statement: 'Rebuilt outcome')
    [discussion, comment, outcome].each do |record|
      record.versions.create!(event: 'update')
      record.update_column(:versions_count, 999)
    end
    item.update_column(:child_count, 999)
    group.update_columns(memberships_count: 999, pending_memberships_count: 999, admin_memberships_count: 999,
                         polls_count: 999, discussions_count: 999, poll_templates_count: 999, subgroups_count: 999,
                         org_members_count: 999)
    topic.update_columns(active_polls_count: 999, seen_by_count: 999)
    user.update_column(:memberships_count, 999)
    empty = Group.create!(name: 'Empty rebuilt group', group_privacy: 'secret')
    empty.update_columns(memberships_count: 999, polls_count: 999)
    timestamp = group.updated_at

    RebuildRetainedRecordCounts.new.up

    group.reload
    assert_equal group.memberships.count, group.memberships_count
    assert_equal group.memberships.pending.count, group.pending_memberships_count
    assert_equal group.admin_memberships.count, group.admin_memberships_count
    assert_equal group.polls.count, group.polls_count
    assert_equal group.discussions.kept.count, group.discussions_count
    assert_equal group.poll_templates.kept.count, group.poll_templates_count
    assert_equal group.subgroups.count, group.subgroups_count
    assert_equal Membership.active.where(group_id: group.id_and_subgroup_ids).distinct.count(:user_id), group.org_members_count
    assert_equal timestamp, group.updated_at
    assert_equal topic.polls.active.count, topic.reload.active_polls_count
    assert_equal topic.topic_readers.where.not(last_read_at: nil).count, topic.seen_by_count
    assert_equal user.memberships.count, user.reload.memberships_count
    assert_equal [0, 0], empty.reload.attributes.values_at('memberships_count', 'polls_count')
    assert_equal item.children.count, item.reload.child_count
    [discussion, comment, outcome].each do |record|
      assert_equal record.versions.count, record.reload.versions_count
    end
  end
end
