class MotionsController < GroupBaseController
  before_filter :check_motion_destroy_permissions, only: :destroy
  # TODO: Change to "except" (whitelisting) instead of "only" (blacklisting)
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
    destroy! { @motion.group }
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

    def check_motion_destroy_permissions
      unless resource.can_be_deleted_by?(current_user)
        flash[:error] = "You do not have permission to delete this motion."
        redirect_to :back
      end
    end

    def check_motion_close_permissions
      unless resource.can_be_closed_by?(current_user)
        flash[:error] = "You do not have permission to close this motion."
        redirect_to :back
      end
    end

    def check_motion_update_permissions
      unless resource.can_be_edited_by?(current_user)
        flash[:error] = "Only the author can edit a motion."
        redirect_to :back
      end
    end

    def check_motion_create_permissions
      unless group.users.include?(current_user)
        flash[:error] = "You don't have permission to create a motion for this group."
        redirect_to :back
      end
    end
end
