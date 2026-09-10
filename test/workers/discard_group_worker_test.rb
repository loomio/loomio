require "test_helper"

class DiscardGroupWorkerTest < ActiveSupport::TestCase
  setup { ENV["CLEANUP_ENABLED"] = "1" }
  teardown { ENV.delete("CLEANUP_ENABLED") }

  test "silently discards a group" do
    group = groups(:orphan_group_tree)

    assert_no_enqueued_jobs(only: [ActionMailer::MailDeliveryJob, DestroyGroupWorker]) do
      DiscardGroupWorker.perform_now(group.id)
    end

    assert group.reload.discarded?
  end

  test "does not discard when cleanup is disabled" do
    group = groups(:orphan_group_tree)
    ENV.delete("CLEANUP_ENABLED")

    DiscardGroupWorker.perform_now(group.id)

    assert group.reload.kept?
  end
end
