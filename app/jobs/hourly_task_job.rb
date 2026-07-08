class HourlyTaskJob < ApplicationJob
  def perform
    hour = Time.now.hour

    puts "#{DateTime.now.iso8601} Loomio hourly tasks"
    ThrottleService.reset!('hour')
    EventBus.broadcast('loomio_hourly_tick', hour)
    ExpireLapsedPollsWorker.perform_later
    PublishClosingSoonWorker.perform_later
    OpenScheduledPollsWorker.perform_later
    SendTaskRemindersWorker.perform_later
    RouteReceivedEmailsWorker.perform_later
    LoginToken.where("created_at < ?", 1.hours.ago).delete_all
    Identity.stale(days: 7).delete_all
    Bookmark.discarded.where("discarded_at < ?", 24.hours.ago).delete_all
    GeoLocationWorker.perform_later

    SendDailyCatchUpEmailWorker.perform_later

    if hour == 0
      ThrottleService.reset!('day')
      DestroyExpiredDemoGroupsWorker.perform_later
      # GenericWorker.perform_later('CleanupService', 'delete_orphan_records')
      # GenericWorker.perform_later('CleanupService', 'destroy_orphan_users')
      EventBus.broadcast('loomio_daily_tick')
      PublishReviewDueWorker.perform_later
      DeleteOldReceivedEmailsWorker.perform_later
      GroomDuplicateTagsWorker.perform_later
    end

    EnsureDemoQueueWorker.perform_later

    if hour == 0 && Time.now.mday == 1
      UpdateBlockedDomainsWorker.perform_later
    end
  end
end
