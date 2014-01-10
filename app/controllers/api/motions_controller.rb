class Api::MotionsController < Api::BaseController

  def create
    @motion = Motion.new(permitted_params.motion)
    @motion.author = current_user
    @motion.discussion = Discussion.find(@motion.discussion_id)
    @event = MotionService.create(@motion)

    render_event_or_invalid_model(@event, @motion)
  end

  def vote
    @vote = Vote.new(permitted_params.vote)
    @vote.user = current_user
    @vote.motion = Motion.find(params[:motion_id])
    @event = VoteService.cast(@vote)

    render_event_or_invalid_model(@event, @vote)
  end
end
