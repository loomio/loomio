class HourlyTaskJob < ApplicationJob
  def perform
    hour = Time.now.hour

    puts "#{DateTime.now.iso8601} Loomio hourly tasks"
    ThrottleService.reset!('hour')
    EventBus.broadcast('loomio_hourly_tick', hour)
    GenericWorker.perform_later('PollService', 'expire_lapsed_polls')
    GenericWorker.perform_later('PollService', 'publish_closing_soon')
    GenericWorker.perform_later('PollService', 'open_scheduled_polls')
    GenericWorker.perform_later('TaskService', 'send_task_reminders')
    GenericWorker.perform_later('ReceivedEmailService', 'route_all')
    LoginToken.where("created_at < ?", 1.hours.ago).delete_all
    Identity.stale(days: 7).delete_all
    Bookmark.discarded.where("discarded_at < ?", 24.hours.ago).delete_all
    GeoLocationWorker.perform_later

    SendDailyCatchUpEmailWorker.perform_later

    if hour == 0
      ThrottleService.reset!('day')
      GenericWorker.perform_later('DemoService', 'destroy_expired_demo_groups')
      # GenericWorker.perform_later('CleanupService', 'delete_orphan_records')
      # GenericWorker.perform_later('CleanupService', 'destroy_orphan_users')
      EventBus.broadcast('loomio_daily_tick')
      GenericWorker.perform_later('OutcomeService', 'publish_review_due')
      GenericWorker.perform_later('ReceivedEmailService', 'delete_old_emails')
    end

    SolidCable::Message.prune
    GenericWorker.perform_later('DemoService', 'ensure_queue')

    if hour == 0 && Time.now.mday == 1
      UpdateBlockedDomainsWorker.perform_later
    end
  end
end
