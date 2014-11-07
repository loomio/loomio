class API::VotesController < API::RestfulController
  load_resource only: [:create]

  def index
    @votes = Vote.where(motion: @motion)
                 .most_recent
                 .order(:created_at)
    respond_with_collection
  end

  def create
    VoteService.create vote: @vote, actor: current_user
    respond_with_resource
  end

  def my_votes
    @votes = @discussion.votes.most_recent.for_user(current_user)
    respond_with_collection
  end

  private
  def vote_params
    params.require(:vote).permit(:position, :statement, :motion_id)
  end


end
