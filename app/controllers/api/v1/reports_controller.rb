class Api::V1::ReportsController < Api::V1::RestfulController
  def index
    start_at = Date.parse(params.fetch(:start_month, 12.months.ago.to_date.iso8601[0..-4]) + "-01")
    end_at = Date.parse(params.fetch(:end_month, Date.today.iso8601[0..-4]) + "-01") + 1.month
    interval = params.fetch(:interval, 'month')
    group_scope = params.fetch(:group_scope, 'custom')
    group_scope = 'custom' unless %w[all my custom].include?(group_scope)
    group_scope = 'my' if group_scope == 'all' && !current_user.is_admin?
    section = params.fetch(:section, 'base')

    membership_group_ids = current_user.group_ids
    all_group_ids = Group.where(parent_id: membership_group_ids).pluck(:id) | membership_group_ids
    all_groups_mode = group_scope == 'all'

    group_ids = case group_scope
    when 'all'
      []
    when 'my'
      all_group_ids
    else
      ids = params.fetch(:group_ids, '').split(',').map(&:to_i)
      ids & (current_user.is_admin? ? ids : current_user.group_ids)
    end
    group_ids = group_ids.uniq
    report_group_ids = group_ids.presence || [-1]

    all_groups_list = Group.where(id: all_group_ids).order("parent_id NULLS FIRST, name asc").pluck(:id, :name).map {|pair| {id: pair[0], name: pair[1] } }
    all_groups_list.unshift({id: 0, name: I18n.t('sidebar.direct_discussions')}) if current_user.is_admin?

    first_year = Group.where(id: all_group_ids).order("created_at").first&.created_at&.year || Date.today.year

    @report = ReportService.new(
      interval: interval,
      group_ids: all_groups_mode ? nil : report_group_ids,
      all_groups: all_groups_mode,
      start_at: start_at,
      end_at: end_at
    )

    meta = {
      first_year: first_year,
      all_groups: all_groups_list,
      group_ids: group_ids,
      group_scope: group_scope,
      current_user_is_admin: current_user.is_admin?,
    }

    data = case section
    when 'users'
      {
        users: @report.users.map {|u| {id: u.id, name: u.name, country: u.country} },
        discussions_per_user: @report.discussions_per_user,
        comments_per_user: @report.comments_per_user,
        polls_per_user: @report.polls_per_user,
        outcomes_per_user: @report.outcomes_per_user,
        stances_per_user: @report.stances_per_user,
        reactions_per_user: @report.reactions_per_user,
        tag_threads_per_user: @report.tag_threads_per_user,
        tag_threads_authored_per_user: @report.tag_threads_authored_per_user,
      }
    when 'countries'
      users_per_country = @report.users_per_country
      {
        countries: @report.countries,
        discussions_per_country: @report.discussions_per_country,
        comments_per_country: @report.comments_per_country,
        polls_per_country: @report.polls_per_country,
        outcomes_per_country: @report.outcomes_per_country,
        stances_per_country: @report.stances_per_country,
        reactions_per_country: @report.reactions_per_country,
        users_per_country: users_per_country,
        total_users: users_per_country.values.sum.to_f,
      }
    else
      {
        intervals: @report.intervals,
        comments_per_interval: @report.comments_per_interval,
        topics_per_interval: @report.topics_per_interval,
        polls_per_interval: @report.polls_per_interval,
        stances_per_interval: @report.stances_per_interval,
        outcomes_per_interval: @report.outcomes_per_interval,
        topics_count: @report.topics_count,
        discussion_topics_count: @report.discussion_topics_count,
        poll_topics_count: @report.poll_topics_count,
        polls_count: @report.polls_count,
        polls_with_outcomes_count: @report.polls_with_outcomes_count,
        tag_names: @report.tag_names,
        tag_counts: @report.tag_counts,
        tag_counts_per_interval: @report.tag_counts_per_interval,
      }
    end

    render json: meta.merge(data)
  end
end
