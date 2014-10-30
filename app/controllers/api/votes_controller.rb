class API::VotesController < API::BaseController
  
  def index
    @votes = Vote.joins(:motion)
                 .where("motions.discussion_id = ?", params[:discussion_id])
                 .for_user(params[:user_id])
                 .where(age: 0)
    render json: @votes
  end

  def create
    @vote = Vote.new(permitted_params.api_vote)
    @vote.user = current_user
    @vote.motion = Motion.find(@vote.motion_id)
    @event = MotionService.cast_vote(@vote)
    render_event_or_model_error(@event, @motion)
  end
end

