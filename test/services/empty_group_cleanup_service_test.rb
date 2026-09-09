require 'test_helper'
require 'stringio'

class EmptyGroupCleanupServiceTest < ActiveSupport::TestCase
  setup do
    @cutoff = subscriptions(:trial_cleanup_discarded).expires_at
    # Reuse the lifecycle matrix, assigning expired trials only within this test.
    @root = groups(:orphan_group_tree)
    @child = groups(:orphan_subgroup)
    @child.update_columns(discarded_at: 1.day.ago)
    @eligible_names = [ :orphan_group_tree, :used_multiple_members_group,
                       :used_revoked_membership_tree, :used_discussion_template_group,
                       :used_poll_template_group, :used_attachment_group ]
    (@eligible_names + [ :used_topic_group, :used_discarded_topic_tree ]).each do |name|
      groups(name).update_columns(subscription_id: Subscription.create!(plan: 'trial', expires_at: @cutoff).id)
    end
    groups(:used_recent_subgroup).update_columns(parent_id: groups(:used_discarded_topic_tree).id)
    groups(:used_discarded_topic_subgroup).update_columns(discarded_at: 1.day.ago, parent_id: groups(:used_recent_subgroup).id)
    [ :cleanup_active_free, :cleanup_active_paid, :cleanup_canceled_free ].each do |name|
      subscriptions(name).update_columns(expires_at: @cutoff)
    end
    @tree_ids = [ @root.id, @child.id ].sort
    @eligible_ids = (@eligible_names.map { |name| groups(name).id } + [ groups(:trial_cleanup_discarded).id ]).sort
    @deleted_ids = (@eligible_ids + [ @child.id, groups(:used_revoked_membership_subgroup).id ]).sort
  end

  test 'fixture matrix excludes every ineligible tree using actual topics rather than counters' do
    plan = EmptyGroupCleanupService.audit(cohort: :trial, before: @cutoff)
    assert_equal @eligible_ids, plan[:root_ids].sort
    assert_equal @tree_ids, plan[:trees][@root.id]
    assert_equal 0, groups(:used_topic_group).discussions_count
    assert_equal 0, groups(:trial_cleanup_poll).polls_count
    assert topics(:cleanup_discarded_topic).discarded_at
    assert groups(:trial_cleanup_discarded).discarded_at
    assert Group.exists?(@root.id), 'audit must not delete'
  end

  test 'trial deletion preserves other groups accounts and direct topics' do
    membership = @root.add_member!(users(:user))
    @child.add_member!(users(:member))
    groups_before = Group.ids.sort
    users_before = User.ids.sort
    topics_before = Topic.ids.sort
    assert_no_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
      EmptyGroupCleanupService.delete!(cohort: :trial, io: StringIO.new)
    end
    assert_equal groups_before - @deleted_ids, Group.ids.sort
    assert_not Membership.exists?(membership.id)
    assert_equal users_before, User.ids.sort
    assert_equal topics_before, Topic.ids.sort
    assert Topic.exists?(topics(:direct_topic).id)
  end

  test 'eligibility starts exactly sixty days after expiry' do
    travel_to @cutoff + 60.days - 1.second do
      assert_not_includes EmptyGroupCleanupService.audit(cohort: :trial)[:root_ids], @root.id
    end
    travel_to @cutoff + 60.days do
      assert_includes EmptyGroupCleanupService.audit(cohort: :trial)[:root_ids], @root.id
    end
  end

  test 'rechecks eligibility and preserves a tree that gains a topic after planning' do
    original = EmptyGroupCleanupService.method(:audit)
    replacement = lambda do |**args|
      plan = original.call(**args)
      discussions(:discussion).topic.update_columns(group_id: @root.id)
      plan
    end
    io = StringIO.new
    result = EmptyGroupCleanupService.stub(:audit, replacement) do
      EmptyGroupCleanupService.delete!(cohort: :trial, io: io, before: @cutoff)
    end
    assert Group.exists?(@root.id)
    assert_equal 1, result[:skipped_roots]
    assert io.string.lines.map { |line| JSON.parse(line) }.any? { |entry| entry['type'] == 'skipped' && entry['root_id'] == @root.id }
  end

  test 'manual deletion honors limits and records exact deleted tree IDs' do
    plan = EmptyGroupCleanupService.audit(cohort: :trial, before: @cutoff, limit: 1)
    tree_ids = plan[:group_ids]
    groups_before = Group.ids.sort
    io = StringIO.new
    result = EmptyGroupCleanupService.delete!(cohort: :trial, io: io, before: @cutoff, limit: 1)
    assert_equal({ deleted_roots: 1, deleted_groups: tree_ids.size, skipped_roots: 0 }, result)
    assert_equal groups_before - tree_ids, Group.ids.sort
    entries = io.string.lines.map { |line| JSON.parse(line) }
    assert_equal tree_ids, entries.find { |e| e['type'] == 'deleted' }['group_ids']
    assert_equal 'plan', entries.first['type']
    assert_equal 'complete', entries.last['type']
    assert_raises(ArgumentError) { EmptyGroupCleanupService.audit(cohort: :trial, limit: 0) }
  end

  test "free cohort selects old topic-free trees and applies subscription safety exclusions" do
    before = 60.days.ago
    recent = groups(:used_recent_group)
    recent.update_columns(subscription_id: Subscription.create!(plan: "free").id)

    used = groups(:used_topic_group)
    used.update_columns(subscription_id: Subscription.create!(plan: "free").id)

    billing = groups(:trial_cleanup_billing)
    billing.subscription.update_columns(plan: "free")

    shared = groups(:trial_cleanup_shared)
    shared.subscription.update_columns(plan: "free")

    conflicting = groups(:trial_cleanup_child_subscription)
    conflicting.subscription.update_columns(plan: "free")

    root_ids = EmptyGroupCleanupService.audit(cohort: :free, before: before)[:root_ids]

    assert_includes root_ids, groups(:orphan_free_group).id
    assert_includes root_ids, groups(:used_canceled_free_group).id
    assert_not_includes root_ids, recent.id
    assert_not_includes root_ids, used.id
    assert_not_includes root_ids, billing.id
    assert_not_includes root_ids, shared.id
    assert_not_includes root_ids, groups(:trial_cleanup_shared_other).id
    assert_not_includes root_ids, conflicting.id
  end

  test "rejects unsupported cohorts" do
    assert_raises(ArgumentError) { EmptyGroupCleanupService.audit(cohort: :paid) }
  end
end
