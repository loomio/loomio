class VotesController < BaseController
  before_filter :require_motion_voting

  def new
    @vote = motion.most_recent_vote_of(current_user) || Vote.new
    @vote.position = params[:position] if params[:position]
  end

  def create
    @vote = Vote.new(permitted_params.vote)
    @vote.motion = motion
    @vote.author = current_user

    if VoteService.create(vote: @vote, actor: current_user)
      flash[:success] = t("success.position_submitted")
      redirect_to @vote.motion.discussion
    else
      render :new
    end
  end

  def update
    create
  end

  private
    def require_motion_voting
      if motion.closed?
        flash[:notice] = t(:"unable_to_vote.motion_closed")
        redirect_to dashboard_path
      end
    end

    def motion
      @motion ||= Motion.friendly.find params[:motion_id]
    end
end
