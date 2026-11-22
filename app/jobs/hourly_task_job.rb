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
    RetentionService.destroy_discarded_groups if AppConfig.discarded_group_deletion_after_days.present?
    RetentionService.destroy_discarded_subgroups if AppConfig.discarded_subgroup_deletion_after_days.present?
    RetentionService.destroy_discarded_threads if DestroyTopicWorker.enabled?

    if hour == 0
      ThrottleService.reset!('day')
      DestroyExpiredDemoGroupsWorker.perform_later
      DiscardExpiredTrialsWorker.perform_later if DiscardExpiredTrialsWorker.enabled?
      DestroyOrphanUsersWorker.perform_later if DestroyOrphanUsersWorker.enabled?
      PublishReviewDueWorker.perform_later
    end
  end
end
