class VotesController < BaseController
  before_filter :require_user_can_vote

  def new
    @vote = motion.most_recent_vote_of(current_user) || Vote.new
    @vote.position = params[:position] if params[:position]
  end

  def create
    @vote = Vote.new(permitted_params.vote)
    @vote.motion = motion
    @vote.user = current_user

    if MotionService.cast_vote(@vote)
      Measurement.increment('votes.create.success')
      flash[:success] = t("success.position_submitted")
      redirect_to @motion
    else
      Measurement.increment('votes.create.errors')
      render :new
    end
  end

  def update
    create
  end

  private
    def require_user_can_vote
      unless can?(:vote, motion)
        if motion.closed?
          flash[:notice] = t(:"unable_to_vote.motion_closed")
        else
          flash[:notice] = t(:"unable_to_vote.permission_denied")
        end
        redirect_to dashboard_path
      end
    end

    def motion
      @motion ||= Motion.friendly.find params[:motion_id]
    end
end
