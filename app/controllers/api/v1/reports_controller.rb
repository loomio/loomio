class Api::V1::ReportsController < Api::V1::RestfulController
  def index
    start_at = Date.parse(params.fetch(:start_month, 12.months.ago.to_date.iso8601[0..-4]) + "-01")
    end_at = Date.parse(params.fetch(:end_month, Date.today.iso8601[0..-4]) + "-01") + 1.month
    interval = params.fetch(:interval, 'month')
    user_group_ids = current_user.group_ids
    group_ids = params.fetch(:group_ids).split(',').map(&:to_i)
    all_group_ids = Group.where("id IN (:group_ids) OR parent_id IN (:group_ids)", group_ids: Group.where(id: group_ids).pluck(:id, :parent_id).flatten.uniq).pluck(:id).uniq
    all_groups = Group.where(id: all_group_ids).order("parent_id NULLS FIRST, name asc").pluck(:id, :name).map {|pair| {id: pair[0], name: pair[1] } }
    first_year = Group.where(id: all_group_ids).order("created_at").first.created_at.year

    if current_user.is_admin?
      all_groups.unshift({id: 0, name: I18n.t('sidebar.direct_discussions')})
    else
      group_ids = group_ids & current_user.group_ids
      all_group_ids = all_group_ids & current_user.group_ids
    end

    @report = ReportService.new(interval: interval, group_ids: group_ids, start_at: start_at, end_at: end_at)
    render json: {
      first_year: first_year,
      all_groups: all_groups,
      intervals: @report.intervals,

      comments_per_interval: @report.comments_per_interval,
      discussions_per_interval: @report.discussions_per_interval,
      polls_per_interval: @report.polls_per_interval,
      stances_per_interval: @report.stances_per_interval,
      outcomes_per_interval: @report.outcomes_per_interval,

      discussions_count: @report.discussions_count,
      discussions_with_polls_count: @report.discussions_with_polls_count,
      polls_count: @report.polls_count,
      polls_with_outcomes_count: @report.polls_with_outcomes_count,

      tag_names: @report.tag_names,
      discussion_tag_counts: @report.discussion_tag_counts,
      poll_tag_counts: @report.poll_tag_counts,
      tag_counts: @report.tag_counts,
      users: @report.users.map {|u| {id: u.id, name: u.name, country: u.country} },
      discussions_per_user: @report.discussions_per_user,
      comments_per_user: @report.comments_per_user,
      polls_per_user: @report.polls_per_user,
      outcomes_per_user: @report.outcomes_per_user,
      stances_per_user: @report.stances_per_user,
      reactions_per_user: @report.reactions_per_user,
      countries: @report.countries,
      discussions_per_country: @report.discussions_per_country,
      comments_per_country: @report.comments_per_country,
      polls_per_country: @report.polls_per_country,
      outcomes_per_country: @report.outcomes_per_country,
      stances_per_country: @report.stances_per_country,
      reactions_per_country: @report.reactions_per_country,
      users_per_country: @report.users_per_country,
      total_users: @report.users_per_country.values.sum.to_f,
    }
  end
end
