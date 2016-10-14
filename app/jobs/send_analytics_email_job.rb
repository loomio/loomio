class SendAnalyticsEmailJob < ActiveJob::Base
  def perform
    Group.with_analytics.find_each do |group|
      BaseMailer.send_bulk_mail(to: group.admins) do |user|
        UserMailer.delay(priority: 10).analytics(user: user, group: group)
      end
    end
  end
end
