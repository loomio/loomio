# Shared by topic lists in the API and initial HTML responses, so group,
# subgroup, privacy and filter rules are applied before either is serialized.
class TopicListQuery
  attr_reader :user, :params

  def initialize(user:, params:)
    @user = user
    @params = params.with_indifferent_access
  end

  def records
    records = TopicQuery.relevant_to(
      user: user,
      or_subgroups: %w[all mine].include?(params[:subgroups]),
      group_ids: group_ids,
      only_direct: params.has_key?(:direct),
      only_unread: params.has_key?(:unread)
    ).with_topicable.recent_activity_first.order(id: :desc)

    if params[:topicable_type].present?
      records = records.where(topicable_type: params[:topicable_type])
    end

    case params[:filter]
    when 'locked'
      records = records.locked
    when 'unlocked'
      records = records.not_locked
    end

    tags = Array(params[:tags]).reject(&:blank?)
    records = records.tagged(tags) if tags.any?

    if params[:last_activity_gte].present?
      records = records.where('topics.last_activity_at >= ?', Time.zone.parse(params[:last_activity_gte]))
    end

    if params[:q].present? && params[:topicable_type] == 'Discussion'
      records = records.joins("INNER JOIN discussions ON discussions.id = topics.topicable_id")
                       .where("discussions.title ILIKE ?", "%#{params[:q]}%")
    end

    records
  end

  private

  def group_ids
    return [] unless params[:group_id].present?

    group = Group.find(params[:group_id])
    case params[:subgroups]
    when 'all'
      [group.id] + group.subgroup_ids
    when 'mine'
      if user.is_logged_in?
        [group.id].concat(user.group_ids & group.id_and_subgroup_ids)
      else
        [group.id]
      end
    else
      [group.id]
    end.compact.uniq
  end
end
