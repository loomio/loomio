class HourlyTaskJob < ApplicationJob
  def perform
    now = Time.current.utc
    hour = now.hour

    ThrottleService.reset!('hour')
    EventBus.broadcast('loomio_hourly_tick', hour)
    PublishClosingSoonWorker.perform_later
    SendTaskRemindersWorker.perform_later
    RetryPendingEmailsWorker.perform_later
    LoginToken.where("created_at <= ?", LoginToken::EXPIRATION.minutes.ago).delete_all
    Session.purge_revoked!
    SpamRuleHit.purge_expired!
    TrialInvitationRecipient.purge_expired!
    Identity.stale(days: 7).delete_all
    Bookmark.discarded.where("discarded_at < ?", 24.hours.ago).delete_all
    GeoLocationWorker.perform_later

    SendDigestEmailWorker.perform_later
    EnsureDemoQueueWorker.perform_later
    PurgeService.destroy_discarded_groups
    PurgeService.destroy_discarded_subgroups
    PurgeService.destroy_discarded_threads

    if hour == 0
      ThrottleService.reset!('day')
      DestroyExpiredDemoGroupsWorker.perform_later
      DestroyOrphanUsersWorker.perform_later
      PublishReviewDueWorker.perform_later
    end
  end
end
