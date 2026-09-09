require "test_helper"

class CleanupTrialGroupsWorkerTest < ActiveSupport::TestCase
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
end
