# frozen_string_literal: true

class Admin::DashboardController < Admin::BaseController
  def show
    render Views::Admin::Dashboard.new(stats: dashboard_stats)
  end

  private

  def dashboard_stats
    since = 30.days.ago
    stats = [
      ["Total users", User.count],
      ["Active users", User.active.count],
      ["Deactivated users", User.deactivated.count],
      ["Users joined in 30 days", User.where(created_at: since..).count],
      ["Total groups", Group.count],
      ["Active groups", Group.where(archived_at: nil).count],
      ["Archived groups", Group.archived.count],
      ["Groups created in 30 days", Group.where(created_at: since..).count],
      ["Active memberships", Membership.active.accepted.count],
      ["Discussions", Discussion.count],
      ["Polls", Poll.count],
      ["Comments", Comment.count]
    ]
    if Object.const_defined?("LoomioSubs")
      stats.concat([
        ["Subscriptions", Subscription.count],
        ["Active subscriptions", Subscription.active.count]
      ])
    end
    stats
  end
end
