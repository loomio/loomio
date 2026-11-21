require "test_helper"

class HourlyTaskJobTest < ActiveSupport::TestCase
  test "expires ended-session history without depending on optional orphan cleanup" do
    cleanup_before = ENV.delete("CLEANUP_ENABLED")
    retention_before = ENV.delete("LOOMIO_SESSION_RETENTION_DAYS")
    freeze_time do
      expired = users(:user).sessions.create!(created_at: 90.days.ago, revoked_at: 60.days.ago)
      retained = users(:user).sessions.create!(created_at: 90.days.ago, revoked_at: 1.day.ago)

      HourlyTaskJob.perform_now

      refute Session.exists?(expired.id)
      assert Session.exists?(retained.id)
    end
  ensure
    cleanup_before.nil? ? ENV.delete("CLEANUP_ENABLED") : ENV["CLEANUP_ENABLED"] = cleanup_before
    retention_before.nil? ? ENV.delete("LOOMIO_SESSION_RETENTION_DAYS") : ENV["LOOMIO_SESSION_RETENTION_DAYS"] = retention_before
  end

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

  test "the legacy cleanup flag no longer schedules the orphan sweep" do
    cleanup_before = ENV["CLEANUP_ENABLED"]
    ENV["CLEANUP_ENABLED"] = "1"
    travel_to Time.utc(2026, 9, 5) do
      assert_no_enqueued_jobs(only: CleanupOrphanRecordsWorker) { HourlyTaskJob.perform_now }
    end
  ensure
    ENV["CLEANUP_ENABLED"] = cleanup_before
  end

  test "schedules the combined group job with orphan cleanup off" do
    cleanup_before = ENV.delete("CLEANUP_ENABLED")
    groups_before = ENV["LOOMIO_GROUP_CLEANUP_ENABLED"]
    ENV["LOOMIO_GROUP_CLEANUP_ENABLED"] = "enabled"

    travel_to Time.utc(2026, 9, 8) do
      assert_no_enqueued_jobs(only: CleanupOrphanRecordsWorker) do
        assert_enqueued_with(job: CleanupGroupsWorker) { HourlyTaskJob.perform_now }
      end
    end
  ensure
    ENV["CLEANUP_ENABLED"] = cleanup_before
    ENV["LOOMIO_GROUP_CLEANUP_ENABLED"] = groups_before
  end

  test "orphan account cleanup can be scheduled independently" do
    previous = ENV.delete("LOOMIO_DELETE_ORPHAN_USERS_AFTER_X_DAYS")
    travel_to Time.utc(2026, 9, 8) do
      assert_no_enqueued_jobs(only: CleanupOrphanUsersWorker) { HourlyTaskJob.perform_now }

      ENV["LOOMIO_DELETE_ORPHAN_USERS_AFTER_X_DAYS"] = "90"
      assert_enqueued_with(job: CleanupOrphanUsersWorker) do
        assert_no_enqueued_jobs(only: CleanupOrphanRecordsWorker) { HourlyTaskJob.perform_now }
      end
    end
  ensure
    ENV["LOOMIO_DELETE_ORPHAN_USERS_AFTER_X_DAYS"] = previous
  end

  test "permanent group deletion is only scheduled at midnight UTC when a delay is configured" do
    previous = ENV.delete("LOOMIO_DELETE_DISCARDED_GROUPS_AFTER_X_DAYS")
    group = groups(:orphan_group_tree)
    midnight = Time.utc(2026, 9, 8)

    travel_to midnight do
      group.discard!(at: 36.days.ago)
      assert_no_enqueued_jobs(only: DestroyGroupWorker) { HourlyTaskJob.perform_now }

      ENV["LOOMIO_DELETE_DISCARDED_GROUPS_AFTER_X_DAYS"] = "35"
      assert_enqueued_with(job: DestroyGroupWorker, args: [group.id, group.discarded_at.iso8601(6)]) do
        HourlyTaskJob.perform_now
      end
    end

    travel_to midnight + 1.hour do
      assert_no_enqueued_jobs(only: DestroyGroupWorker) { HourlyTaskJob.perform_now }
    end
  ensure
    ENV["LOOMIO_DELETE_DISCARDED_GROUPS_AFTER_X_DAYS"] = previous
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
