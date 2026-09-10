require 'test_helper'

class CleanupEmptyGroupsTest < ActiveSupport::TestCase
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
    @eligible_ids = @eligible_names.map { |name| groups(name).id }.sort
  end

  test 'fixture matrix excludes every ineligible tree using actual topics rather than counters' do
    plan = CleanupService.audit_empty_groups(plan: :trial, before: @cutoff)
    assert_equal @eligible_ids, plan[:root_ids].sort
    assert_equal @tree_ids, plan[:trees][@root.id]
    assert_equal 0, groups(:used_topic_group).discussions_count
    assert_equal 0, groups(:trial_cleanup_poll).polls_count
    assert topics(:cleanup_discarded_topic).discarded_at
    assert groups(:trial_cleanup_discarded).discarded_at
    assert Group.exists?(@root.id), 'audit must not delete'
  end

  test 'eligibility starts exactly sixty days after expiry' do
    travel_to @cutoff + 60.days - 1.second do
      assert_not_includes CleanupService.audit_empty_groups(plan: :trial)[:root_ids], @root.id
    end
    travel_to @cutoff + 60.days do
      assert_includes CleanupService.audit_empty_groups(plan: :trial)[:root_ids], @root.id
    end
  end

  test 'manual cleanup queues bounded background jobs' do
    plan = CleanupService.audit_empty_groups(plan: :trial, before: @cutoff, limit: 1)
    result = nil
    assert_enqueued_with(job: DiscardGroupWorker, args: ->(args) { args == [ plan[:root_ids].first ] }) do
      result = CleanupService.enqueue_empty_group_discard!(plan: :trial, before: @cutoff, limit: 1)
    end
    assert_equal({ queued_roots: 1 }, result)
    assert Group.exists?(plan[:root_ids].first)
    assert_raises(ArgumentError) { CleanupService.audit_empty_groups(plan: :trial, limit: 0) }
  end

  test "free subscription plan selects old topic-free trees and applies subscription safety exclusions" do
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

    root_ids = CleanupService.audit_empty_groups(plan: :free, before: before)[:root_ids]

    assert_includes root_ids, groups(:orphan_free_group).id
    assert_includes root_ids, groups(:used_canceled_free_group).id
    assert_not_includes root_ids, recent.id
    assert_not_includes root_ids, used.id
    assert_not_includes root_ids, billing.id
    assert_not_includes root_ids, shared.id
    assert_not_includes root_ids, groups(:trial_cleanup_shared_other).id
    assert_not_includes root_ids, conflicting.id
  end

  test "rejects unsupported subscription plans" do
    assert_raises(ArgumentError) { CleanupService.audit_empty_groups(plan: :paid) }
  end
end
