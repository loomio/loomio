class MotionsController < GroupBaseController
  before_filter :check_group_read_permissions
  before_filter :check_motion_create_permissions, only: [:create, :new]
  before_filter :check_motion_update_permissions, only: [:update, :edit]
  before_filter :check_motion_destroy_permissions, only: :destroy
  before_filter :check_motion_close_permissions, only: [:open_voting, :close_voting]

  def show
    resource
    @motion.open_close_motion
    @group = @motion.group
    @user_already_voted = @motion.user_has_voted?(current_user)
    @votes_for_graph = @motion.votes_graph_ready
    @vote = Vote.new
  end

  def new
    @motion = Motion.new(group: Group.find(params[:group_id]))
  end

  def create
    @motion = Motion.create(params[:motion])
    @motion.author = current_user
    @motion.group = Group.find(params[:group_id])
    if @motion.save
      redirect_to @motion
    else
      redirect_to :back
    end
  end

  def destroy
    resource
    destroy! { @motion.group }
    flash[:notice] = "Motion deleted."
  end

  # CUSTOM ACTIONS

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

  def toggle_tag_filter
    @motion = Motion.find(params[:id])
    @active_tags = params[:tags]
    @clicked_tag = params[:tag]
    render :partial => "motions/votes_filters", :locals => { clicked_tag: @clicked_tag }, :layout => false, :status => :created
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
