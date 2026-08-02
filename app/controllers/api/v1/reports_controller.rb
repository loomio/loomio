class Api::V1::ReportsController < Api::V1::RestfulController
  def index
    start_at = Date.parse(params.fetch(:start_month, 12.months.ago.to_date.iso8601[0..-4]) + "-01")
    end_at = Date.parse(params.fetch(:end_month, Date.today.iso8601[0..-4]) + "-01") + 1.month
    interval = params.fetch(:interval, 'month')
    section = params.fetch(:section, 'base')

    group = Group.published.find(params[:group_id]) if params[:group_id].present?
    authorize_report!(group)

    group_scope_options = report_scope_options(group)
    group_scope_values = group_scope_options.pluck(:value)
    group_scope = params[:group_scope].presence_in(group_scope_values) || report_scope_default(group)
    all_groups_mode = group_scope == 'all'
    group_ids = report_group_ids(group, group_scope, group_scope_options)
    report_group_ids = group_ids.presence || [-1]

    first_year = if all_groups_mode
      Group.published.minimum(:created_at)&.year
    else
      Group.where(id: group_ids).minimum(:created_at)&.year
    end || Date.today.year

    @report = ReportService.new(
      interval: interval,
      group_ids: all_groups_mode ? nil : report_group_ids,
      all_groups: all_groups_mode,
      start_at: start_at,
      end_at: end_at
    )

    meta = {
      first_year: first_year,
      group_scope_options: group_scope_options,
      group_ids: group_ids,
      group_scope: group_scope,
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

  private

  def authorize_report!(group)
    if group
      current_user.ability.authorize!(:report, group)
    else
      raise CanCan::AccessDenied unless current_user.is_admin?
    end
  end

  def report_scope_options(group)
    options = []
    options << {value: 'all'} if current_user.is_admin?
    if group
      options << {value: 'organisation', group_name: group.name} if can_report_organisation?(group)
      report_scope_groups(group).each do |scope_group|
        options << {
          value: "group:#{scope_group.id}",
          group_id: scope_group.id,
          group_name: scope_group.name,
        }
      end
    end
    options
  end

  def report_scope_default(group)
    return 'all' unless group
    return 'organisation' if can_report_organisation?(group)

    "group:#{group.id}"
  end

  def report_group_ids(group, group_scope, group_scope_options)
    case group_scope
    when 'all'
      []
    when 'organisation'
      organisation_group_ids(group)
    else
      [group_scope_options.find { |option| option[:value] == group_scope }.fetch(:group_id)]
    end
  end

  def report_scope_groups(group)
    return [group] if group.is_subgroup? || can_report_organisation?(group)

    current_user.groups
      .where(id: group.id_and_subgroup_ids)
      .order(Arel.sql('parent_id NULLS FIRST, name ASC'))
  end

  def can_report_organisation?(group)
    group.is_parent? && (current_user.is_admin? || group.admins.exists?(current_user.id))
  end

  def organisation_group_ids(group)
    visible_subgroup_ids = group.subgroups
      .where('is_visible_to_public = TRUE OR is_visible_to_parent_members = TRUE')
      .pluck(:id)
    member_subgroup_ids = current_user.groups.where(parent_id: group.id).pluck(:id)
    [group.id] | visible_subgroup_ids | member_subgroup_ids
  end
end
