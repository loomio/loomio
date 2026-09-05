require "test_helper"

class CleanupInactiveUsersWorkerTest < ActiveSupport::TestCase
  test "runs inactive user cleanup" do
    cleanup_ran = false

    InactiveUserCleanupService.stub(:destroy_orphan_users, -> { cleanup_ran = true }) do
      CleanupInactiveUsersWorker.perform_now
    end

    assert cleanup_ran
  end
end
