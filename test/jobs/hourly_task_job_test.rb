require "test_helper"

class HourlyTaskJobTest < ActiveSupport::TestCase
  test "deletes expired login tokens and retains valid login tokens" do
    valid_token = LoginToken.create!(
      user: users(:user),
      created_at: LoginToken::EXPIRATION.minutes.ago + 1.minute
    )
    expired_token = LoginToken.create!(
      user: users(:user),
      created_at: LoginToken::EXPIRATION.minutes.ago - 1.minute
    )

    HourlyTaskJob.perform_now

    assert LoginToken.exists?(valid_token.id)
    assert_not LoginToken.exists?(expired_token.id)
  end

  test "enqueues orphan cleanup at midnight UTC only when cleanup is enabled" do
    begin
      ENV.delete("CLEANUP_ENABLED")
      travel_to Time.utc(2026, 9, 5) do
        assert_no_enqueued_jobs(only: CleanupOrphanRecordsWorker) do
          HourlyTaskJob.perform_now
        end
      end

      ENV["CLEANUP_ENABLED"] = "1"
      travel_to Time.utc(2026, 9, 5) do
        assert_enqueued_with(job: CleanupOrphanRecordsWorker) do
          HourlyTaskJob.perform_now
        end
      end
    ensure
      ENV.delete("CLEANUP_ENABLED")
    end
  end

  test "does not enqueue orphan cleanup at midnight in another time zone" do
    begin
      ENV["CLEANUP_ENABLED"] = "1"
      travel_to Time.new(2026, 9, 5, 0, 0, 0, "+12:00") do
        assert_no_enqueued_jobs(only: CleanupOrphanRecordsWorker) do
          HourlyTaskJob.perform_now
        end
      end
    ensure
      ENV.delete("CLEANUP_ENABLED")
    end
  end

  test "queues expired-trial warnings at midnight UTC only when cleanup is enabled" do
    begin
      ENV.delete("CLEANUP_ENABLED")
      called = false
      travel_to Time.utc(2026, 9, 8) do
        CleanupService.stub(:warn_and_discard_expired_trial_groups, ->(**) { called = true }) do
          HourlyTaskJob.perform_now
        end
      end
      assert_not called

      ENV["CLEANUP_ENABLED"] = "1"
      called = false
      travel_to Time.utc(2026, 9, 8) do
        CleanupService.stub(:warn_and_discard_expired_trial_groups, -> { called = true }) do
          CleanupService.stub(:destroy_discarded_groups, -> { raise "destroying discarded groups is not enabled" }) do
            HourlyTaskJob.perform_now
          end
        end
      end
      assert called
      travel_to Time.utc(2026, 9, 8, 12) do
        CleanupService.stub(:warn_and_discard_expired_trial_groups, ->(**) { raise "should not run" }) do
          HourlyTaskJob.perform_now
        end
      end
    ensure
      ENV.delete("CLEANUP_ENABLED")
    end
  end
end
