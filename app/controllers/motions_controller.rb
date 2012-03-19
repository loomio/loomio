class MotionsController < GroupBaseController
  before_filter :ensure_group_member

  def new
    @motion = Motion.new(group: Group.find(params[:group_id]))
  end

  def destroy
    resource
    if @motion.has_admin_user?(current_user) || @motion.author == current_user
      destroy! { @motion.group }
      flash[:notice] = "Motion deleted."
    else
      flash[:error] = "You do not have significant priviledges to do that."
      redirect_to @motion
    end
  end

  def show
    resource
    @motion.open_close_motion
    @user_already_voted = @motion.user_has_voted?(current_user)
    @votes_for_graph = @motion.votes_graph_ready
    @vote = Vote.new
  end

  def create
    @motion = Motion.create(params[:motion])
    @motion.author = current_user
    @motion.group = Group.find(params[:group_id])
    if @motion.save!
      redirect_to @motion
    else
      redirect_to edit_motion_path(@motion)
    end
  end

  def close_voting
    resource
    @motion.set_close_date(Time.now)
    redirect_to motion_path(@motion)
  end

  def open_voting
    resource
    @motion.set_close_date(Time.now + 1.week)
    redirect_to motion_path(@motion)
  end

  def edit
    resource
    if @motion.can_be_edited_by?(current_user)
      edit!
    else
      flash[:error] = "Only the facilitator or author can edit a motion."
      redirect_to motion_url(@motion)
    end
  end

  private

    def group
      @group ||= find_group
    end

    def find_group
      if (params[:id] && (params[:id] != "new"))
        Motion.find(params[:id]).group
      elsif params[:group_id]
        Group.find(params[:group_id])
      end
    end
end
