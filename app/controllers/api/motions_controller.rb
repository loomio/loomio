class Api::MotionsController < Api::BaseController

  def create
    @motion = Motion.new(permitted_params.motion)
    @motion.author = current_user
    @motion.discussion = Discussion.find(@motion.discussion_id)
    @event = MotionService.create(@motion)
    if @event
      render 'api/events/show'
    else
      render 'api/validation_error', locals: {model: @motion}, status: 400
    end
  end
end
