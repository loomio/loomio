class Admin::StatsController < Admin::BaseController
  helper_method :format_percents
  helper_method :data_for
  layout 'admin'

  def aaarrr
    #arrrrrrr!!!
    @cohorts = Cohort.all
  end

  def cohorts
    @measurements = MeasurementService.measurement_names
    @cohorts = Cohort.all
    @ages = CohortService.avg_by_age(cohort: @cohorts.first, measurement: @measurements.first).map{|e| e['age'].to_i}
    #data: pad_data(CohortService.avg_by_age(cohort: cohort, measurement: @measurement).map{|e| e['avg'].to_f.round(2)}) }
  end

  def data_for(cohort, measurement)
    CohortService.avg_by_age(cohort: cohort, measurement: measurement).map{|e| e['avg'].to_f.round(2)}
  end

  def weekly_activity
    @metrics = []
    (0..52).each do |i|
      date_range = (i+1).weeks.ago..i.weeks.ago
      @metrics << { weeks_ago:   i,
                    comments:    Comment.where(   created_at: date_range ).count,
                    groups:      Group.parents_only.where(     created_at: date_range ).count,
                    users:       User.where(      created_at: date_range ).count,
                    votes:       Vote.where(      created_at: date_range ).count,
                    motions:     Motion.where(    created_at: date_range ).where('author_id != 5562').count,
                    discussions: Discussion.where(created_at: date_range ).where('author_id != 5562').count }
    end
    render layout: false
  end

  def group_activity
    @metrics = []
    groups = []
    if params[:id].present?
      groups << Group.find(params[:id])
    elsif params[:from].present? and params[:until].present?
      groups = Group.parents_only.where('created_at > ? and created_at < ?',  params[:from], params[:until])
    end
    groups.each do |group|
      unless (group.memberships.count == 0)
        @metrics << group_metrics_counts(group)
        group.subgroups.each do |g|
          @metrics << group_metrics_counts(g)
        end
      end
    end
    render layout: false
  end

  def daily_activity
    @metrics = []
    groups = []
    if params[:from].present? and params[:until].present?
      date_range = (params[:from].to_date)..(params[:until].to_date)
      if params[:group_ids].present?
        group_ids = params[:group_ids].split(',')
        groups = Group.where(id: group_ids.map(&:to_i))
      else
        groups = Group.parents_only.where(created_at: date_range)
      end
      days = date_range.to_a
      groups.each do |group|
        days.each do |day|
          if (group.memberships.where('created_at <= ?', day).count > 0)
            @metrics << group_metrics_daily_counts(group, day)
          end
        end
      end
    end
    render layout: false
  end

  def first_30_days
    @metrics = []
    groups = []
    group_ids = params[:group_ids].split(',')
    groups = Group.where(id: group_ids.map(&:to_i))
    groups.each do |group|
      start = group.created_at.to_date
      thirty_days_later = group.created_at.to_date + 30.days
      finish = Date.today < thirty_days_later ? Date.today : thirty_days_later
      date_range = (start..finish)
      days = date_range.to_a
      days.each do |day|
        if (group.memberships.where('created_at <= ?', day).count > 0)
          @metrics << daily_activity_counts(group, day)
        end
      end
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
    { id: g.id,
      name: g.full_name,
      admin_group_url: admin_group_path(g),
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
      coordinators: g.coordinators.map(&:name),
      creator_id: g.creator_id,
      locale: g.locale,
      financial_nature: g.financial_nature
    }
  end

  def group_metrics_daily_counts(group, day)
    org_discussions = Discussion.where(group_id: [group.org_group_ids]).where('author_id != 5562')
    org_comments = Comment.where(discussion_id: org_discussions.map(&:id))
    org_motions = Motion.where(discussion_id: org_discussions.map(&:id)).where('author_id != 5562')
    org_outcomes_count = org_motions.where('outcome IS NOT NULL').count
    org_memberships = Membership.where(group_id: [group.org_group_ids]).select(:user_id).distinct
    daily_votes_count = 0
    org_motions.each do |m|
      org_votes = Vote.where(motion_id: m.id)
      daily_votes_count += org_votes.where('created_at <= ?', day).count
    end
    {
      day: day,
      id: group.id,
      name: group.full_name,
      subgroups: group.subgroups.where('created_at <= ?', day).count,
      discussions: org_discussions.where('created_at <= ?', day).count,
      comments: org_comments.where('created_at <= ?', day).count,
      motions: org_motions.where('created_at <= ?', day).count,
      daily_votes: daily_votes_count,
      outcomes: org_outcomes_count,
      members: org_memberships.where('created_at <= ?', day).count,
      financial_nature: group.financial_nature,
      creator_id: group.creator_id,
      locale: group.locale
    }
  end

  def daily_activity_counts(group, day)
    votes_count = 0
    discussions       = Discussion.where(group_id: [group.org_group_ids]).where('author_id != 5562').where('created_at <= ?', day)
    comments_count    = Comment.where(discussion_id: discussions.map(&:id)).where('created_at <= ?', day).count
    motions           = Motion.where(discussion_id: discussions.map(&:id)).where('author_id != 5562').where('created_at <= ?', day)
    motions.each do |m|
      votes_count    += Vote.where(motion_id: m.id).where('created_at <= ?', day).count
    end
    memberships       = Membership.where(group_id: [group.org_group_ids]).where('created_at <= ?', day)
    members_count     = memberships.select(:user_id).distinct.count
    outcomes_count    = motions.where('outcome IS NOT NULL').where('created_at <= ?', day).count
    subgroups_count   = group.subgroups.where('created_at <= ?', day).count
    days_old          = (day.to_date - group.created_at.to_date).to_i
    motions_count     = motions.count
    discussions_count = discussions.count
    {
      day: day,
      days_old: days_old,
      id: group.id,
      name: group.full_name,
      subgroups: subgroups_count,
      discussions: discussions_count,
      comments: comments_count,
      motions: motions_count,
      daily_votes: votes_count,
      outcomes: outcomes_count,
      members: members_count,
      financial_nature: group.financial_nature,
      creator_id: group.creator_id,
      locale: group.locale,
      total: subgroups_count + discussions_count + comments_count + motions_count + votes_count + outcomes_count + members_count
    }
  end

  def format_percents(float)
    float > 0 ? "#{(float * 100).round(1)}%" : "0"
  end
end
