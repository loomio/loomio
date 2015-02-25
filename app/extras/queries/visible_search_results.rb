class Queries::VisibleSearchResults < Delegator
  def initialize(user: nil, query: '', limit: 5)
    super Search.new(user, query, limit)
  end

  def __getobj__
    @relation
  end

  def __setobj__(obj)
    @relation = obj
  end

end
