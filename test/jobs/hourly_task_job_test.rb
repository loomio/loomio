require "test_helper"

class HourlyTaskJobTest < ActiveSupport::TestCase
  test "expires ended-session history without depending on optional orphan cleanup" do
    cleanup_before = ENV.delete("LOOMIO_DELETE_ORPHAN_USERS_AFTER_X_DAYS")
    retention_before = ENV.delete("LOOMIO_SESSION_RETENTION_DAYS")
    freeze_time do
      expired = users(:user).sessions.create!(created_at: 90.days.ago, revoked_at: 60.days.ago)
      retained = users(:user).sessions.create!(created_at: 90.days.ago, revoked_at: 1.day.ago)

      HourlyTaskJob.perform_now

      refute Session.exists?(expired.id)
      assert Session.exists?(retained.id)
    end
  ensure
    ENV["LOOMIO_DELETE_ORPHAN_USERS_AFTER_X_DAYS"] = cleanup_before
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

  test "schedules trial cleanup only at midnight with a configured delay" do
    trials_before = ENV.delete("LOOMIO_DISCARD_TRIALS_AFTER_X_DAYS")
    midnight = Time.utc(2026, 9, 8)

    travel_to midnight do
      assert_no_enqueued_jobs(only: DiscardExpiredTrialsWorker) { HourlyTaskJob.perform_now }

      ENV["LOOMIO_DISCARD_TRIALS_AFTER_X_DAYS"] = "60"
      assert_no_enqueued_jobs(only: CleanupOrphanRecordsWorker) do
        assert_enqueued_with(job: DiscardExpiredTrialsWorker) { HourlyTaskJob.perform_now }
      end
    end

    travel_to midnight + 1.hour do
      assert_no_enqueued_jobs(only: DiscardExpiredTrialsWorker) { HourlyTaskJob.perform_now }
    end
  ensure
    ENV["LOOMIO_DISCARD_TRIALS_AFTER_X_DAYS"] = trials_before
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

  test "permanent group deletion tops up hourly only when a delay is configured" do
    previous = ENV.delete("LOOMIO_DELETE_DISCARDED_GROUPS_AFTER_X_DAYS")
    group = groups(:orphan_group_tree)
    hour = Time.utc(2026, 9, 8, 13)

    travel_to hour do
      group.discard!(at: 36.days.ago)
      assert_no_enqueued_jobs(only: DestroyGroupWorker) { HourlyTaskJob.perform_now }

      ENV["LOOMIO_DELETE_DISCARDED_GROUPS_AFTER_X_DAYS"] = "35"
      assert_enqueued_with(job: DestroyGroupWorker, args: [group.id, group.discarded_at.iso8601(6)]) do
        HourlyTaskJob.perform_now
      end
    end
  ensure
    ENV["LOOMIO_DELETE_DISCARDED_GROUPS_AFTER_X_DAYS"] = previous
  end

  test "permanent subgroup and thread deletion top up hourly only when configured" do
    subgroups_before = ENV.delete("LOOMIO_DELETE_DISCARDED_SUBGROUPS_AFTER_X_DAYS")
    threads_before = ENV.delete("LOOMIO_DELETE_DISCARDED_THREADS_AFTER_X_DAYS")
    subgroup = groups(:orphan_subgroup)
    topic = topics(:direct_topic)
    hour = Time.utc(2026, 9, 8, 13)

    travel_to hour do
      subgroup.discard!(at: 31.days.ago)
      topic.update_column(:discarded_at, 15.days.ago)
      assert_no_enqueued_jobs(only: [ DestroyGroupWorker, DestroyTopicWorker ]) { HourlyTaskJob.perform_now }

      ENV["LOOMIO_DELETE_DISCARDED_SUBGROUPS_AFTER_X_DAYS"] = "30"
      ENV["LOOMIO_DELETE_DISCARDED_THREADS_AFTER_X_DAYS"] = "14"
      assert_enqueued_with(job: DestroyGroupWorker, args: [subgroup.id, subgroup.discarded_at.iso8601(6)]) do
        assert_enqueued_with(job: DestroyTopicWorker, args: [topic.id, topic.discarded_at.iso8601(6)]) do
          HourlyTaskJob.perform_now
        end
      end
    end
  ensure
    ENV["LOOMIO_DELETE_DISCARDED_SUBGROUPS_AFTER_X_DAYS"] = subgroups_before
    ENV["LOOMIO_DELETE_DISCARDED_THREADS_AFTER_X_DAYS"] = threads_before
  end
end
