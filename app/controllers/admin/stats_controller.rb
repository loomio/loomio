class Admin::StatsController < Admin::BaseController
  helper_method :format_percents

  def weekly_activity
    @metrics = []
    (0..51).each do |i|
      date_range = (i+1).weeks.ago..i.weeks.ago
      @metrics << { weeks_ago:   i,
                    comments:    Comment.where(   created_at: date_range ).count,
                    users:       User.where(      created_at: date_range ).count,
                    votes:       Vote.where(      created_at: date_range ).count,
                    motions:     Motion.where(    created_at: date_range ).count,
                    discussions: Discussion.where(created_at: date_range ).count }
    end
    render layout: false
  end

  def group_metrics
    @metrics = []
    group = Group.find params[:id]
    @metrics << group_metrics_counts(group)
    group.subgroups.each do |g|
      @metrics << group_metrics_counts(g)
    end
    render layout: false
  end

  def retention
    @metrics = []
    (1..19).each do |months_ago|
      @metrics << retention_metrics_counts(months_ago)
    end
    render layout: false
  end

  def retention_metrics_counts(months_ago)
    start_date = months_ago.months.ago.at_beginning_of_month
    end_date = start_date + 1.month
    r30_date = start_date + 1.month
    r90_date = start_date + 3.months

    acquired_groups = Group.parents_only.where(created_at: start_date..end_date)
    activated_groups = acquired_groups.more_than_n_members(2)
    small_groups = acquired_groups.more_than_n_members(2).less_than_n_members(20)
    medium_groups = acquired_groups.more_than_n_members(20).less_than_n_members(50)
    large_groups = acquired_groups.more_than_n_members(50)

    retained_groups_30 = activated_groups.active_discussions_since(r30_date)
    retained_groups_90 = activated_groups.active_discussions_since(r90_date)
    retained_small_groups_90 = small_groups.active_discussions_since(r90_date)
    retained_medium_groups_90 = medium_groups.active_discussions_since(r90_date)
    retained_large_groups_90 = large_groups.active_discussions_since(r90_date)

    acquired_count = acquired_groups.count
    activated_count = activated_groups.count
    trial_count = acquired_groups.count - activated_count
    r30 = retained_groups_30.count.to_f / activated_groups.count
    r90 = retained_groups_90.count.to_f / activated_groups.count
    r90_small = retained_small_groups_90.count.to_f / small_groups.count
    r90_medium = retained_medium_groups_90.count.to_f / medium_groups.count
    r90_large = retained_large_groups_90.count.to_f / large_groups.count

    { months_ago: months_ago,
      acquired_count: acquired_count,
      activated_count: activated_count,
      trial_count: trial_count,
      retained_30_count: retained_groups_30.count,
      r30: r30,
      retained_90_count: retained_groups_90.count,
      r90: r90,
      start_date: start_date,
      end_date: end_date,
      r30_date: r30_date,
      r90_date: r90_date,
      small_groups: small_groups.count,
      medium_groups: medium_groups.count,
      large_groups: large_groups.count,
      retained_small_groups_90: retained_small_groups_90.count,
      retained_medium_groups_90: retained_medium_groups_90.count,
      retained_large_groups_90: retained_large_groups_90.count,
      r90_small: r90_small,
      r90_medium: r90_medium,
      r90_large: r90_large
    }
  end

  def group_metrics_counts(g)
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

  def format_percents(float)
    float > 0 ? "#{(float * 100).round(1)}%" : "0"
  end
end
