Search = Struct.new(:user, :query, :limit) do

  def discussion_results
    @discussions ||= SearchVectors::Discussion.search_for(query, user: user, limit: limit)
  end

  def motion_results
    @motions     ||= SearchVectors::Motion.search_for(query, user: user, limit: limit)
  end

  def comment_results
    @comments    ||= SearchVectors::Comment.search_for(query, user: user, limit: limit)
  end

  def results
    discussion_results + motion_results + comment_results
  end
end