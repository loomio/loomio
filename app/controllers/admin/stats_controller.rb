class Admin::StatsController < Admin::BaseController
  def group_metrics
    @metrics = []
    group = Group.find params[:id]
    @metrics << get_counts(group)
    group.subgroups.each do |g|
      @metrics << get_counts(g)
    end
    render layout: false
  end

  private

  def get_counts(g)
    comments_count = 0
    comment_authors = []
    discussion_authors = []
    motion_authors = []
    voters = []
    last_activity_at = 10.years.ago
    g.discussions.each do |d|
      discussion_authors = discussion_authors | [d.author]
      comments_count += d.comments.count
      if d.last_activity_at > last_activity_at
        last_activity_at = d.last_activity_at
      end
      comment_authors = comment_authors | d.commenters
    end
    g.motions.each do |m|
      motion_authors = motion_authors | [m.author]
      voters = voters | m.voters
    end
    active_users = voters | motion_authors | discussion_authors | comment_authors
    outcomes_count = g.motions.where('outcome IS NOT NULL').count
    {id: g.id, name: g.name,
      discussions: g.discussions.count,
      comments: comments_count,
      motions: g.motions.count,
      outcomes: outcomes_count,
      members: g.members.count,
      comment_authors: comment_authors.count,
      discussion_authors: discussion_authors.count,
      motion_authors: motion_authors.count,
      voters: voters.count,
      active_users: active_users.count,
      created_at: g.created_at,
      last_activity_at: last_activity_at,
      coordinators: g.coordinators.map(&:name)}
  end

end
