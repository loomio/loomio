class MotionsController < GroupBaseController
  before_filter :check_group_read_permissions
  before_filter :check_motion_create_permissions, only: [:create, :new]
  before_filter :check_motion_update_permissions, only: [:update, :edit]
  before_filter :check_motion_destroy_permissions, only: :destroy
  before_filter :check_motion_close_permissions, only: [:open_voting, :close_voting]

  def update
    resource
    update! { discussion_url(@motion.discussion_id) }
  end

  def new
    @motion = Motion.new
    @motion.group_id = params[:group_id]
  end

  def create
    @motion = Motion.new(params[:motion])
    @motion.author = current_user
    if @motion.save
      flash[:success] = "Motion sucessfully created."
      redirect_to discussion_path(@motion.discussion)
    else
      flash[:success] = "Motion sucessfully created."
      redirect_to :back
    end
  end

  def show
    proposal = Motion.find(params[:id])
    discussion = proposal.discussion_id
    redirect_to "/discussions/#{discussion}?proposal=#{proposal.id}"
  end

  def destroy
    resource
    destroy! { @motion.group }
    flash[:success] = "Motion deleted."
  end

  # CUSTOM ACTIONS

  def close_voting
    resource
    @motion.close_voting!
    redirect_to discussion_url(@motion.discussion_id)
  end

  def open_voting
    resource
    @motion.open_voting!
    redirect_to discussion_path(@motion.discussion_id)
  end

  def edit
    resource
    if @motion.can_be_edited_by?(current_user)
      edit!
    else
      flash[:error] = "Only the facilitator or author can edit a motion."
      redirect_to discussion_url(@motion.discussion_id)
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
