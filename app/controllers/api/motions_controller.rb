class API::MotionsController < API::BaseController
  
  def index
    @motions = Motion.where(discussion_id: params[:discussion_id])
    render json: @motions, root: :proposals
  end

  def create
    @motion = Motion.new(permitted_params.api_motion)
    @motion.author = current_user
    @motion.discussion = Discussion.find(@motion.discussion_id)
    @event = MotionService.create(@motion)

    render_event_or_model_error(@event, @motion)
  end
end
