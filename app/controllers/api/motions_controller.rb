class API::MotionsController < API::BaseController

  def create
    @motion = Motion.new(permitted_params.motion)
    @motion.author = current_user
    @motion.discussion = Discussion.find(@motion.discussion_id)
    @event = MotionService.create(@motion)

    render_event_or_model_error(@event, @motion)
  end

  def vote
    params[:vote] = {position: params[:position], statement: params[:statement]}
    @vote = Vote.new(permitted_params.vote)
    @vote.user = current_user
    @vote.motion = Motion.find(params[:id])
    @event = VoteService.cast(@vote)

    render_event_or_model_error(@event, @vote)
  end
end
