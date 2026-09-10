require "test_helper"

class WarnAndDiscardExpiredTrialGroupWorkerTest < ActiveSupport::TestCase
  setup { ENV["CLEANUP_ENABLED"] = "1" }
  teardown { ENV.delete("CLEANUP_ENABLED") }

  test "warns group admins and discards an expired trial" do
    group = groups(:trial_cleanup_poll)
    group.add_admin!(users(:admin))

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      WarnAndDiscardExpiredTrialGroupWorker.perform_now(group.id)
    end

    assert group.reload.discarded?
  end

  test "does not warn or discard when cleanup is disabled" do
    group = groups(:trial_cleanup_poll)
    group.add_admin!(users(:admin))
    ENV.delete("CLEANUP_ENABLED")

    assert_no_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
      WarnAndDiscardExpiredTrialGroupWorker.perform_now(group.id)
    end

    assert group.reload.kept?
  end
end
