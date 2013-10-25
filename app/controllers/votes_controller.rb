class VotesController < GroupBaseController
  # I would like to introduce load_and_authorise_resource rather than use inherited_resources - rob

  inherit_resources
  belongs_to :motion

  def new
    @motion = Motion.find(params[:motion_id])
    @vote = @motion.most_recent_vote_of(current_user)
    @vote = Vote.new unless @vote
    @vote.position = params[:position]
  end

  def destroy
    resource
    if @motion.voting?
      destroy! { @motion.discussion }
    else
      flash[:error] = t("error.cant_modify_position")
      redirect_to @motion.discussion
    end
  end

  def create
    @motion = Motion.find(params[:motion_id])
    if @motion.voting?
      @vote = Vote.new(permitted_params.vote)
      @vote.motion = @motion
      @vote.user = current_user
      if @vote.save
        flash[:success] = t("success.position_submitted")
      else
        flash[:warning] = t("warning.position_not_submitted")
      end
      redirect_to @motion
    else
      flash[:error] = t("error.cant_state_position")
      redirect_to @motion
    end
  end

  def update
    @motion = Motion.find(params[:motion_id])
    if @motion.voting?
      params[:vote].delete(:id)
      @vote = Vote.new(permitted_params.vote)
      @vote.motion = @motion
      @vote.user = current_user
      if @vote.save
        flash[:success] = t("success.position_updated")
      else
        flash[:error] = t("error.position_not_updated")
      end
    else
      flash[:error] = "You cannot edit your position after the proposal has closed."
    end
    redirect_to @motion.discussion
  end

  private

    def group
      Motion.find(params[:motion_id]).group
    end
end
