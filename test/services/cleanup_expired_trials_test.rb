require "test_helper"

class CleanupExpiredTrialsTest < ActiveSupport::TestCase
  test "the configured trial cutoff applies to both silent discards and populated trial notices" do
    trials_before = ENV["LOOMIO_DISCARD_TRIALS_AFTER_X_DAYS"]
    ENV["LOOMIO_DISCARD_TRIALS_AFTER_X_DAYS"] = "45"

    empty_trial = groups(:trial_cleanup_recent)
    empty_trial.subscription.update!(expires_at: 46.days.ago)
    empty_free = groups(:orphan_free_group)
    populated_trial = groups(:trial_cleanup_poll)
    populated_trial.subscription.update!(expires_at: 45.days.ago - 1.hour)
    populated_trial.add_admin!(users(:admin))
    billing_trial = groups(:trial_cleanup_billing)
    clear_enqueued_jobs

    assert_enqueued_jobs 1, only: WarnAndDiscardExpiredTrialGroupWorker do
      assert_no_enqueued_jobs(only: [ActionMailer::MailDeliveryJob, DestroyGroupWorker]) do
        DiscardExpiredTrialsWorker.perform_now
      end
    end
    assert empty_trial.reload.discarded?
    assert empty_free.reload.kept?
    assert billing_trial.reload.kept?
    assert populated_trial.reload.kept?

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      perform_enqueued_jobs(only: WarnAndDiscardExpiredTrialGroupWorker)
    end
    assert populated_trial.reload.discarded?
  ensure
    ENV["LOOMIO_DISCARD_TRIALS_AFTER_X_DAYS"] = trials_before
  end

  test "newly eligible populated trials are queued before the oldest trials" do
    now = Time.current
    old_trial = groups(:trial_cleanup_poll)
    old_trial.subscription.update_columns(expires_at: now - 1.year)
    new_trial = groups(:trial_cleanup_recent)
    new_trial.subscription.update_columns(expires_at: now - 45.days)
    topics(:direct_topic).update_columns(group_id: new_trial.id)
    clear_enqueued_jobs

    RetentionService.warn_and_discard_expired_trial_groups(now: now, retention: 45.days)

    notifications = enqueued_jobs.select { |job| job[:job] == WarnAndDiscardExpiredTrialGroupWorker }
    assert_equal [new_trial.id, old_trial.id], notifications.map { |job| job[:args].first }
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

    group_ids = RetentionService.expired_trial_groups.pluck(:id).sort

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
    assert_not_includes RetentionService.expired_trial_groups(now: now).pluck(:id), trial_group.id

    trial_group.subscription.update!(expires_at: now - 60.days)
    assert_includes RetentionService.expired_trial_groups(now: now).pluck(:id), trial_group.id
  end

  test "cancelled subscriptions are excluded" do
    assert_not_includes RetentionService.expired_trial_groups.pluck(:id), groups(:used_canceled_free_group).id
  end

end
