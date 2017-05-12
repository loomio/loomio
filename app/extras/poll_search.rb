PollSearch = Struct.new(:user) do
  include LoadAndAuthorize
  STATUS_FILTERS = %w(active closed).freeze
  USER_FILTERS   = %w(authored_by participation_by).freeze

  def perform(filters = {})
    results = searchable_records.with_includes
    results = results.where(discussion_id: filter_group(filters[:group_key]).discussion_ids) if filters[:group_key]
    results = results.send(filters[:status])      if STATUS_FILTERS.include?(filters[:status].to_s)
    results = results.send(filters[:user], user)  if USER_FILTERS.include?(filters[:user].to_s)
    results = results.search_for(filters[:query]) if filters[:query].present?
    results.order(closed_at: :desc, closing_at: :asc)
  end

  def results_count
    searchable_records.count
  end

  private

  def searchable_records
    @searchable_records ||= Poll.from("(#{searchable_records_sql}) as polls")
  end

  def searchable_records_sql
    [
      Queries::VisiblePolls.new(user: user, group_ids: user.group_ids),
      user.participated_polls,
      user.polls
    ].map(&:to_sql).join(" UNION ")
  end

  def filter_group(key)
    @group ||= user.ability.authorize! :show, Group.find(key) if key
  end
end
