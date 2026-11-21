require "test_helper"

class CleanupOrphanRecordsWorkerTest < ActiveSupport::TestCase
  test "retrying a historical job does not run inactive account cleanup" do
    cleanup_before = ENV["CLEANUP_ENABLED"]
    ENV["CLEANUP_ENABLED"] = "1"

    CleanupService.stub(:delete_inactive_orphan_users, -> { flunk "legacy job attempted to delete users" }) do
      assert_nothing_raised { CleanupOrphanRecordsWorker.perform_now }
    end
  ensure
    ENV["CLEANUP_ENABLED"] = cleanup_before
  end
end
