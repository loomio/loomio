class MotionsController < GroupBaseController
  #rob would like to remove inherited_resources...
  inherit_resources
  before_filter :load_resource_by_key, except: [:create, :index]
  authorize_resource except: [:create, :index, :show]
  before_filter :authenticate_user!, except: [:show, :index]
  before_filter :check_group_read_permissions, :only => :show

  def create
    @discussion = Discussion.find(params[:motion][:discussion_id])
    if @discussion.current_motion
      redirect_to @discussion
      flash[:error] = t(:"error.proposal_already_exists")
    else
      @motion = current_user.authored_motions.new(permitted_params.motion)
      @group = GroupDecorator.new(@motion.group)
      authorize! :create, @motion
      if @motion.save
        flash[:success] = t("success.proposal_created")
        redirect_to @discussion
      else
        flash[:warning] = t("warning.proposal_not_created")
        render action: :new
      end
    end
  end

  def index
    # NOTE (Jon): This currently only returns closed motions, which
    # means it should probably be renamed to something like "closed_motions"
    if params[:group_id].present?
      @group = Group.find(params[:group_id])
      if cannot? :show, @group
        head 401
      else
        @closed_motions = @group.motions.closed.page(params[:page])
        render :layout => false if request.xhr?
      end
    else
      authenticate_user!
      @closed_motions= current_user.motions.closed.page(params[:page])
      render :layout => false if request.xhr?
    end
  end

  def show
    discussion = @motion.discussion
    if @motion == discussion.current_motion
      redirect_to discussion_url(discussion)
    else
      redirect_to discussion_url(discussion, proposal: @motion)
    end
  end

  def destroy
    resource
    @motion.destroy
    redirect_to group_url(@motion.group)
    flash[:success] = t("success.proposal_deleted")
  end

  def close
    MotionService.close_by_user(@motion, current_user)
    flash[:success] = t("success.motion_closed")
    redirect_to discussion_url(@motion.discussion, proposal: @motion)
  end

  def create_outcome
    if MotionService.create_outcome(@motion, permitted_params.motion, current_user)
      flash[:success] = t("success.motion_outcome_created")
    else
      flash[:error] = t("error.motion_outcome_not_created")
    end
    redirect_to discussion_url(@motion.discussion, proposal: @motion)
  end

  def update_outcome
    if MotionService.update_outcome(@motion, permitted_params.motion, current_user)
      flash[:success] = t("success.motion_outcome_updated")
    else
      flash[:error] = t("error.motion_outcome_not_updated")
    end
    redirect_to discussion_url(@motion.discussion, proposal: @motion)
  end

  def edit_close_date
    safe_values = {}
    safe_values[:close_at_date] = params[:motion][:close_at_date]
    safe_values[:close_at_time] = params[:motion][:close_at_time]

    if @motion.update_attributes(safe_values)
      Events::MotionCloseDateEdited.publish!(@motion, current_user)
      flash[:success] = t("success.close_date_changed")
    else
      flash[:error] = t("error.invalid_close_date")
    end
    redirect_to discussion_url(@motion.discussion)
  end

  private
    def load_resource_by_key
      @motion ||= Motion.find_by_key!(params[:id])
    end

    def group
      @group ||= find_group
    end

    def find_group
      if (params[:id] && (params[:id] != "new"))
        Motion.find_by_key!(params[:id]).group
      elsif params[:motion][:discussion_id]
        Discussion.find(params[:motion][:discussion_id]).group
      end
    end
end
