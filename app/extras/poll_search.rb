PollSearch = Struct.new(:user) do
  include LoadAndAuthorize
  STATUS_FILTERS = %w(active closed).freeze
  USER_FILTERS   = %w(authored_by participation_by).freeze

  def perform(filters = {})
    results = searchable_records
    results = results.where(discussion_id: filter_group(filters[:group_key]).discussion_ids) if filters[:group_key]
    results = results.send(filters[:status])      if STATUS_FILTERS.include?(filters[:status].to_s)
    results = results.send(filters[:user], user)  if USER_FILTERS.include?(filters[:user].to_s)
    results = results.search_for(filters[:query]) if filters[:query].present?
    results.order(closed_at: :desc, closing_at: :asc)
  end

  def results_count
    searchable_ids.count
  end

  private

  def searchable_records
    @searchable_records ||= Poll.where(id: searchable_ids)
  end

  # TODO: combine this into a single SQL query, rather than 3 separate plucks
  def searchable_ids
    @searchable_ids ||= [
      Queries::VisiblePolls.new(user: user), # polls in my groups
      Poll.participation_by(user),           # polls I've participated in
      user.polls                             # polls I've started
    ].map { |c| c.pluck(:id) }.flatten.uniq
  end

  def filter_group(key)
    @group ||= user.ability.authorize! :show, Group.find(key) if key
  end
end
