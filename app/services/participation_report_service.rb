class ParticipationReportService
  def self.fetch(actor:, params:)
    new(actor: actor, params: params).fetch
  end

  def initialize(actor:, params:)
    @actor = actor
    @params = params
  end

  # Resolves the caller's permitted group scope once, then builds the requested
  # report section. Both the in-product report and B2 API use this path so their
  # authorization, delegate filtering, and aggregate counts stay identical.
  def fetch
    start_at = Date.parse(@params.fetch(:start_month, 12.months.ago.to_date.iso8601[0..-4]) + "-01")
    end_at = Date.parse(@params.fetch(:end_month, Date.today.iso8601[0..-4]) + "-01") + 1.month
    interval = @params.fetch(:interval, 'month')
    group_scope = @params.fetch(:group_scope, 'custom')
    group_scope = 'custom' unless %w[all my custom].include?(group_scope)
    group_scope = 'my' if group_scope == 'all' && !@actor.is_admin?
    section = @params.fetch(:section, 'base')
    member_type = @params[:member_type].presence
    raise ArgumentError, "invalid member_type value: #{member_type}" unless [ nil, 'delegate' ].include?(member_type)

    membership_group_ids = @actor.group_ids
    candidate_group_ids = Group.where(parent_id: membership_group_ids).pluck(:id) | membership_group_ids
    all_group_ids = GroupQuery.visible_to(user: @actor).where(id: candidate_group_ids).pluck(:id)
    all_groups_mode = group_scope == 'all'

    group_ids = case group_scope
    when 'all'
      []
    when 'my'
      all_group_ids
    else
      ids = @params.fetch(:group_ids, '').split(',').map(&:to_i)
      ids & (@actor.is_admin? ? ids : @actor.group_ids)
    end
    group_ids = group_ids.uniq
    report_group_ids = group_ids.presence || [ -1 ]

    all_groups_list = Group.where(id: all_group_ids).order("parent_id NULLS FIRST, name asc").pluck(:id, :name).map { |pair| { id: pair[0], name: pair[1] } }
    all_groups_list.unshift({ id: 0, name: I18n.t('sidebar.direct_discussions') }) if @actor.is_admin?

    first_year = Group.where(id: all_group_ids).order("created_at").first&.created_at&.year || Date.today.year
    report = ReportService.new(
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
      current_user_is_admin: @actor.is_admin?
    }

    meta.merge(section_data(report: report, section: section, member_type: member_type))
  end

  private

  def section_data(report:, section:, member_type:)
    case section
    when 'users'
      users_data(report: report, member_type: member_type)
    when 'countries'
      users_per_country = report.users_per_country
      {
        countries: report.countries,
        discussions_per_country: report.discussions_per_country,
        comments_per_country: report.comments_per_country,
        polls_per_country: report.polls_per_country,
        outcomes_per_country: report.outcomes_per_country,
        stances_per_country: report.stances_per_country,
        reactions_per_country: report.reactions_per_country,
        users_per_country: users_per_country,
        total_users: users_per_country.values.sum.to_f
      }
    else
      {
        intervals: report.intervals,
        comments_per_interval: report.comments_per_interval,
        topics_per_interval: report.topics_per_interval,
        polls_per_interval: report.polls_per_interval,
        stances_per_interval: report.stances_per_interval,
        outcomes_per_interval: report.outcomes_per_interval,
        topics_count: report.topics_count,
        discussion_topics_count: report.discussion_topics_count,
        poll_topics_count: report.poll_topics_count,
        polls_count: report.polls_count,
        polls_with_outcomes_count: report.polls_with_outcomes_count,
        tag_names: report.tag_names,
        tag_counts: report.tag_counts,
        tag_counts_per_interval: report.tag_counts_per_interval
      }
    end
  end

  def users_data(report:, member_type:)
    discussions = report.discussions_per_user
    comments = report.comments_per_user
    polls = report.polls_per_user
    outcomes = report.outcomes_per_user
    stances = report.stances_per_user
    stances_issued = report.stances_issued_per_user
    reactions = report.reactions_per_user
    delegate_user_ids = report.delegate_user_ids
    users = (member_type == 'delegate' ? report.users.where(id: delegate_user_ids) : report.users).to_a
    user_ids = users.map(&:id)
    discussions = discussions.slice(*user_ids)
    comments = comments.slice(*user_ids)
    polls = polls.slice(*user_ids)
    outcomes = outcomes.slice(*user_ids)
    stances = stances.slice(*user_ids)
    stances_issued = stances_issued.slice(*user_ids)
    reactions = reactions.slice(*user_ids)

    {
      users: users.map do |user|
        votes_cast = stances[user.id] || 0
        votes_issued = stances_issued[user.id] || 0
        {
          id: user.id,
          name: user.name,
          country: user.country,
          delegate: delegate_user_ids.include?(user.id),
          threads: discussions[user.id] || 0,
          comments: comments[user.id] || 0,
          polls: polls[user.id] || 0,
          votes: votes_cast,
          votes_cast: votes_cast,
          votes_issued: votes_issued,
          votes_missed: votes_issued - votes_cast,
          all_votes_cast: votes_issued.positive? && votes_issued == votes_cast,
          outcomes: outcomes[user.id] || 0,
          reactions: reactions[user.id] || 0
        }
      end,
      discussions_per_user: discussions,
      comments_per_user: comments,
      polls_per_user: polls,
      outcomes_per_user: outcomes,
      stances_per_user: stances,
      stances_issued_per_user: stances_issued,
      reactions_per_user: reactions,
      tag_threads_per_user: filter_tag_users(report.tag_threads_per_user, user_ids),
      tag_threads_authored_per_user: filter_tag_users(report.tag_threads_authored_per_user, user_ids)
    }
  end

  def filter_tag_users(counts, user_ids)
    counts.transform_values { |user_counts| user_counts.slice(*user_ids) }
  end
end
