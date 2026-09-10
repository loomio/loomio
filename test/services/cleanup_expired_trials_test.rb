require "test_helper"

class CleanupExpiredTrialsTest < ActiveSupport::TestCase
  test "daily run queues empty and nonempty expired trials" do
    empty_group = groups(:trial_cleanup_recent)
    nonempty_group = groups(:trial_cleanup_poll)
    empty_group.subscription.update!(expires_at: 61.days.ago)
    clear_enqueued_jobs

    assert_enqueued_jobs 2, only: WarnAndDiscardGroupWorker do
      result = nil
      CleanupService.stub(:expired_trial_groups, ->(now:) { Group.where(id: [empty_group.id, nonempty_group.id]) }) do
        result = CleanupService.warn_and_discard_expired_trial_groups
      end
      assert_equal({ queued_groups: 2 }, result)
    end

    assert empty_group.reload.kept?
    assert nonempty_group.reload.kept?
  end

  test "fixture matrix selects old expired trials" do
    expected = %i[
      trial_cleanup_poll
      trial_cleanup_billing
      trial_cleanup_chargify
      trial_cleanup_shared
      trial_cleanup_shared_other
      trial_cleanup_child_subscription
    ].map { |fixture| groups(fixture).id }.sort

    group_ids = CleanupService.expired_trial_groups.pluck(:id).sort

    assert_equal expected, group_ids
    assert_not_includes group_ids, groups(:trial_cleanup_recent).id
    assert_not_includes group_ids, groups(:trial_cleanup_no_expiry).id
    assert_not_includes group_ids, groups(:trial_cleanup_discarded).id
  end

  test "eligibility starts sixty days after trial expiry" do
    now = Time.current
    trial_group = groups(:trial_cleanup_recent)
    topics(:direct_topic).update!(group_id: trial_group.id)
    trial_group.subscription.update!(expires_at: now - 60.days + 1.second)
    assert_not_includes CleanupService.expired_trial_groups(now: now).pluck(:id), trial_group.id

    trial_group.subscription.update!(expires_at: now - 60.days)
    assert_includes CleanupService.expired_trial_groups(now: now).pluck(:id), trial_group.id
  end

  test "cancelled subscriptions are excluded" do
    assert_not_includes CleanupService.expired_trial_groups.pluck(:id), groups(:used_canceled_free_group).id
  end

end
