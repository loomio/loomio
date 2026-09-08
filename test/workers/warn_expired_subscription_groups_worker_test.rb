require "test_helper"

class WarnExpiredSubscriptionGroupsWorkerTest < ActiveSupport::TestCase
  test "processes a bounded daily batch" do
    called = false
    replacement = lambda do |io:, limit:|
      called = io == $stdout && limit == WarnExpiredSubscriptionGroupsWorker::BATCH_SIZE
    end

    ExpiredSubscriptionGroupCleanupService.stub(:warn_and_schedule!, replacement) do
      WarnExpiredSubscriptionGroupsWorker.perform_now
    end

    assert called
  end
end
