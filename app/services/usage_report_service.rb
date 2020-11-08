class UsageReportService
  def self.send
    return if ENV['DISABLE_USAGE_REPORTING']
    Clients::Loomio.new.send_usage_report!({
      version: Loomio::Version.current,
      groups_count: Group.count,
      users_count: User.count,
      discussions_count: Discussion.count,
      comments_count: Comment.count,
      polls_count: Poll.count,
      stances_count: Stance.count,
      visits_count: Ahoy::Visit.count,
      canonical_host: ENV['CANONICAL_HOST']
    })
  end
end
