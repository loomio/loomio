class API::VotesController < API::RestfulController

  def index
    @votes = Vote.where(motion: @motion)
                 .most_recent
                 .order(:created_at)
    respond_with_collection
  end

  def my_votes
    load_and_authorize_discussion
    @votes = @discussion.votes.most_recent.for_user(current_user)
    respond_with_collection
  end

end
