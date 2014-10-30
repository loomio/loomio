class API::VotesController < API::RestfulController

  def index
    @votes = Vote.where(motion: @motion)
                 .most_recent
                 .order(:created_at)
    respond_with_collection
  end

  def create
    MotionService.cast_vote @vote
    respond_with_resource
  end

  def my_votes
    @votes = @discussion.votes.most_recent.for_user(current_user)
    respond_with_collection
  end

end
