require "test_helper"

class CleanupTrialGroupsWorkerTest < ActiveSupport::TestCase
  setup { ENV["CLEANUP_ENABLED"] = "1" }
  teardown { ENV.delete("CLEANUP_ENABLED") }

  test "processes a bounded daily batch" do
    called = false
    replacement = lambda do |io:, warning_limit:|
      called = io == $stdout && warning_limit == CleanupTrialGroupsWorker::WARNING_LIMIT
    end

    TrialGroupCleanupService.stub(:run!, replacement) do
      CleanupTrialGroupsWorker.perform_now
    end

    assert called
  end

  test "does not run cleanup when cleanup is disabled" do
    ENV.delete("CLEANUP_ENABLED")
    called = false

    TrialGroupCleanupService.stub(:run!, ->(**) { called = true }) do
      CleanupTrialGroupsWorker.perform_now
    end

    assert_not called
  end
end
