class SendAnalyticsEmailJob < ActiveJob::Base
  def perform
    Group.with_analytics.find_each do |group|
      stats = Queries::GroupAnalytics.new(group: group).stats
      BaseMailer.send_bulk_mail(to: group.admins) do |user|
        UserMailer.delay(priority: 10).analytics(user: user, group: group, stats: stats)
      end
    end
  end
end
