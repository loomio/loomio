class MotionsController < GroupBaseController
  load_and_authorize_resource :except => [:new, :create]

  def update
    resource
    update! { discussion_url(@motion.discussion_id) }
  end

  def new
    @motion = Motion.new
    @motion.group_id = params[:group_id]
  end

  def create
    @motion = current_user.authored_motions.new(params[:motion])
    authorize! :create, @motion
    if @motion.save
      flash[:success] = "Proposal successfully created."
      redirect_to discussion_path(@motion.discussion)
    else
      flash[:warning] = "Proposal could not be created"
      redirect_to :back
    end
  end

  def show
    motion = Motion.find(params[:id])
    discussion = motion.discussion
    if motion == discussion.current_motion
      redirect_to discussion_url(discussion)
    else
      redirect_to discussion_url(discussion, proposal: motion)
    end
  end

  def destroy
    resource
    @motion.destroy
    redirect_to group_url(@motion.group)
    flash[:success] = "Proposal deleted."
  end

  # CUSTOM ACTIONS

  def close_voting
    resource
    @motion.close_voting!
    redirect_to discussion_url(@motion.discussion)
  end

  def open_voting
    resource
    @motion.open_voting!
    redirect_to discussion_url(@motion.discussion)
  end

  def edit
    @motion = Motion.find(params[:id])
  end
end
