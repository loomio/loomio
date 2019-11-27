PollSearch = Struct.new(:user) do
  include LoadAndAuthorize
  STATUS_FILTERS = %w(active closed).freeze
  USER_FILTERS   = %w(authored_by participation_by).freeze

  def perform(filters = {})
    results = searchable_records.with_includes
    results = results.where(group_id: filter_group(filters[:group_key], filters[:subgroups])) if filters[:group_key]
    results = results.where(discussion_id: filter_discussion(filters[:discussion_key]).id) if filters[:discussion_key]
    results = results.where(poll_type: filters[:poll_type]) if filters[:poll_type]
    results = results.send(filters[:status])      if STATUS_FILTERS.include?(filters[:status].to_s)
    results = results.send(filters[:user], user)  if USER_FILTERS.include?(filters[:user].to_s)
    results = results.search_for(filters[:query]) if filters[:query].present?
    results.order(closed_at: :desc, closing_at: :asc)
  end

  private

  def searchable_records
    return Poll.none unless searchable_records_sql.present?
    @searchable_records ||= Poll.from("(#{searchable_records_sql}) as polls")
  end

  def searchable_records_sql
    @searchable_records_sql ||= [
      # user.participated_polls,
      user.group_polls,
      user.polls
    ].map(&:to_sql).map(&:presence).compact.join(" UNION ")
  end

  def filter_group(key, subgroups)
    if subgroups == "none"
      Group.friendly.find(key).id
    else
      Group.friendly.find(key).id_and_subgroup_ids
    end
  end

  def filter_discussion(key)
    @discussion ||= user.ability.authorize! :show, Discussion.friendly.find(key) if key
  end
end
