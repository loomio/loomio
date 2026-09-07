require "test_helper"

class CleanupOrphanRecordsWorkerTest < ActiveSupport::TestCase
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
end
