class UsageReportService
  def self.send
    Clients::Loomio.new.send_usage_report!({
      groups_count: Group.count,
      users_count: User.count,
      discussions_count: Discussion.count,
      comments_count: Comment.count,
      polls_count: Poll.count,
      stances_count: Stance.count,
      reactions_count: Reaction.count,
      visits_count: Visit.count,
      canonical_host: ENV['CANONICAL_HOST'],
      support_email: ENV['SUPPORT_EMAIL']
    }) if ENV['USAGE_REPORT_URL']
  end
end
