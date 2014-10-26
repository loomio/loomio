class API::VotesController < API::BaseController
  def create
    @vote = Vote.new(permitted_params.vote)
    @vote.user = current_user
    @vote.motion = Motion.find(@vote.motion_id)
    @event = MotionService.cast_vote(@vote)
    render_event_or_model_error(@event, @motion)
  end
end

