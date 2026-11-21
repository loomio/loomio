require "test_helper"

class WarnAndDiscardExpiredTrialGroupWorkerTest < ActiveSupport::TestCase
  setup do
    @trials_before = ENV["LOOMIO_DISCARD_TRIALS_AFTER_X_DAYS"]
    ENV["LOOMIO_DISCARD_TRIALS_AFTER_X_DAYS"] = "60"
  end

  teardown { ENV["LOOMIO_DISCARD_TRIALS_AFTER_X_DAYS"] = @trials_before }

  test "warns group admins and discards an expired trial" do
    group = groups(:trial_cleanup_poll)
    group.add_admin!(users(:admin))

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      WarnAndDiscardExpiredTrialGroupWorker.perform_now(group.id, only_unused: false)
    end

    assert group.reload.discarded?
  end

  test "does not warn or discard when cleanup is disabled" do
    group = groups(:trial_cleanup_poll)
    group.add_admin!(users(:admin))
    ENV.delete("LOOMIO_DISCARD_TRIALS_AFTER_X_DAYS")

    assert_no_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
      WarnAndDiscardExpiredTrialGroupWorker.perform_now(group.id, only_unused: false)
    end

    assert group.reload.kept?
  end

  test "a job from the retired scheduler does not discard a group" do
    group = groups(:trial_cleanup_poll)
    group.add_admin!(users(:admin))

    assert_no_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
      WarnAndDiscardExpiredTrialGroupWorker.perform_now(group.id)
    end

    assert group.reload.kept?
  end

  test "rechecks eligibility when a queued trial has been extended" do
    group = groups(:trial_cleanup_poll)
    group.subscription.update!(expires_at: 1.week.from_now)

    assert_no_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
      WarnAndDiscardExpiredTrialGroupWorker.perform_now(group.id, only_unused: false)
    end

    assert group.reload.kept?
  end

  test "the dedicated group cleanup rechecks whether a trial became unused after queueing" do
    group = groups(:trial_cleanup_poll)
    group.add_admin!(users(:admin))
    group.topics.update_all(group_id: nil)

    assert_no_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
      WarnAndDiscardExpiredTrialGroupWorker.perform_now(group.id, only_unused: false)
    end
    assert group.reload.kept?
  end

  test "repeated jobs do not warn again" do
    group = groups(:trial_cleanup_poll)
    group.add_admin!(users(:admin))
    WarnAndDiscardExpiredTrialGroupWorker.perform_now(group.id, only_unused: false)

    assert_no_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
      WarnAndDiscardExpiredTrialGroupWorker.perform_now(group.id, only_unused: false)
    end
  end
end
