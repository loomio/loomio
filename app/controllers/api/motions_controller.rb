class API::MotionsController < API::BaseController
  def create
    @motion = Motion.new(permitted_params.api_motion)
    @motion.author = current_user
    @motion.discussion = Discussion.find(@motion.discussion_id)
    @event = MotionService.create(@motion)

    render_event_or_model_error(@event, @motion)
  end
end
