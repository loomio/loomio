class MotionsController < GroupBaseController
  load_and_authorize_resource :except => [:create, :show, :index]
  before_filter :authenticate_user!, :except => [:show, :index, :get_and_clear_new_activity]
  before_filter :check_group_read_permissions, :only => :show

  def create
    if Discussion.find(params[:motion][:discussion_id]).current_motion
      redirect_to @discussion
      flash[:notice] = "A proposal has already been created"
    else
      @motion = current_user.authored_motions.new(params[:motion])
      @motion.close_date = params[:motion][:close_date].to_datetime
      @group = GroupDecorator.new(@motion.group)
      authorize! :create, @motion
    end
    if @motion.save
      flash[:success] = t("success.proposal_created")
      redirect_to discussion_path(@motion.discussion)
    else
      flash[:warning] = t("warning.proposal_not_created")
      redirect_to :back
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
        @closed_motions = @group.motions_closed.page(params[:page]).per(7)
        render :layout => false if request.xhr?
      end
    else
      authenticate_user!
      @closed_motions= current_user.motions_closed.page(params[:page]).per(7)
      render :layout => false if request.xhr?
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
    flash[:success] = t("success.proposal_deleted")
  end

  # CUSTOM ACTIONS

  def close
    resource
    @motion.close_motion! current_user
    redirect_to discussion_url(@motion.discussion, proposal: @motion)
  end

  def edit_outcome
    resource
    motion = Motion.find(params[:motion][:id])
    motion.set_outcome!(params[:motion][:outcome])
    redirect_to discussion_url(motion.discussion, proposal: motion)
  end

  def edit_close_date
    motion = Motion.find(params[:id])
    if motion.set_close_date!((params[:motion][:close_date]).to_datetime, current_user)
      flash[:success] = t("success.close_date_changed")
    else
      flash[:error] = t("error.invalid_close_date")
    end
    redirect_to discussion_url(motion.discussion)
  end

  def get_and_clear_new_activity
    @motion = Motion.find(params[:id])
    @motion_activity = Integer(params[:motion_activity])
    if user_signed_in?
      @user = current_user
      ViewLogger.motion_viewed(@motion, @user)
    end
  end

  private

    def group
      @group ||= find_group
    end

    def find_group
      if (params[:id] && (params[:id] != "new"))
        Motion.find(params[:id]).group
      elsif params[:motion][:discussion_id]
        Discussion.find(params[:motion][:discussion_id]).group
      end
    end
end
