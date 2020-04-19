PollSearch = Struct.new(:user) do
  STATUS_FILTERS = %w(active closed).freeze
  USER_FILTERS   = %w(authored_by participation_by).freeze

  def perform(filters = {})
    @filters = filters
    results = Queries::VisiblePolls.new(user: user)
    results = results.where(group_id: group_ids) if filters[:group_key]
    results = results.where(discussion_id: discussion_id) if filters[:discussion_key]
    results = results.where(poll_type: filters[:poll_type]) if filters[:poll_type]
    results = results.send(status) if status
    # results = results.send(filters[:user], user)  if USER_FILTERS.include?(filters[:user].to_s)
    results = results.search_for(filters[:query]) if filters[:query].present?
    results.order("polls.id desc")
  end

  private
  def status
    @filters[:status] if STATUS_FILTERS.include?(@filters[:status])
  end

  def discussion_id
    Discussion.find_by(key: @filters[:discussion_key]).id
  end

  def group_ids
    if @filters[:subgroups] == "none"
      Group.friendly.find(@filters[:group_key]).id
    else
      Group.friendly.find(@filters[:group_key]).id_and_subgroup_ids
    end
  end
end
