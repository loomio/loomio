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

    if hour == 0
      ThrottleService.reset!('day')
      DestroyExpiredDemoGroupsWorker.perform_later
      if CleanupGroupsWorker.enabled?
        CleanupGroupsWorker.perform_later
      elsif ENV["CLEANUP_ENABLED"].present?
        CleanupService.warn_and_discard_expired_trial_groups
      end
      CleanupService.destroy_discarded_groups if ENV["LOOMIO_DISCARDED_GROUP_DELETION_SCHEDULED"].present?
      CleanupOrphanUsersWorker.perform_later if CleanupOrphanUsersWorker.enabled?
      PublishReviewDueWorker.perform_later
    end
  end
end
