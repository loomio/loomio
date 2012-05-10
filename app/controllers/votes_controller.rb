class VotesController < GroupBaseController
  belongs_to :motion
  # before_filter :ensure_group_member
  # belongs_to :motion

  # def begin_of_association_chain
  #   @motion
  #

  def destroy
    resource
    if @motion.voting?
      destroy! { @motion }
    else
      flash[:error] = "You can only delete your vote during the 'voting' phase"
      redirect_to @motion
    end
  end

  def create
    @motion = Motion.find(params[:motion_id])
    if @motion.voting?
      @vote = Vote.new(params[:vote])
      @vote.motion = @motion
      @vote.user = current_user
      @vote.save
      flash[:notice] = "Your vote has been submitted"
      redirect_to :back
    else
      flash[:error] = "Can only vote in voting phase"
      redirect_to @motion
    end
  end

  def update
    @motion = Motion.find(params[:motion_id])
    if @motion.voting?
      params[:vote].delete(:id)
      @vote = Vote.new(params[:vote])
      @vote.motion = @motion
      @vote.user = current_user
      if @vote.save
        flash[:notice] = "Vote updated."
      else
        flash[:error] = "Could not update vote."
      end
    else
      flash[:error] = "Can only vote in voting phase"
    end
    redirect_to @motion.discussion
  end

  private

    def group
      group = Motion.find(params[:motion_id]).group
    end
end
