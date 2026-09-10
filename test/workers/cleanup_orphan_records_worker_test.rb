require "test_helper"

class CleanupOrphanRecordsWorkerTest < ActiveSupport::TestCase
  setup { ENV["CLEANUP_ENABLED"] = "1" }
  teardown { ENV.delete("CLEANUP_ENABLED") }

  test "runs record and inactive orphan user cleanup" do
    records_cleanup_ran = false
    users_cleanup_ran = false

    CleanupService.stub(:delete_orphan_records, -> { records_cleanup_ran = true }) do
      CleanupService.stub(:delete_inactive_orphan_users, -> { users_cleanup_ran = true }) do
        CleanupOrphanRecordsWorker.perform_now
      end
    end

    assert records_cleanup_ran
    assert users_cleanup_ran
  end

  test "does not run cleanup when cleanup is disabled" do
    ENV.delete("CLEANUP_ENABLED")
    records_cleanup_ran = false
    users_cleanup_ran = false

    CleanupService.stub(:delete_orphan_records, -> { records_cleanup_ran = true }) do
      CleanupService.stub(:delete_inactive_orphan_users, -> { users_cleanup_ran = true }) do
        CleanupOrphanRecordsWorker.perform_now
      end
    end

    assert_not records_cleanup_ran
    assert_not users_cleanup_ran
  end
end
