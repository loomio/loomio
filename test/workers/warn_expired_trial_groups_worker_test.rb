require "test_helper"

class WarnExpiredTrialGroupsWorkerTest < ActiveSupport::TestCase
  test "processes a bounded daily batch" do
    called = false
    replacement = lambda do |io:, limit:|
      called = io == $stdout && limit == WarnExpiredTrialGroupsWorker::BATCH_SIZE
    end

    ExpiredTrialGroupCleanupService.stub(:warn_and_schedule!, replacement) do
      WarnExpiredTrialGroupsWorker.perform_now
    end

    assert called
  end
end
