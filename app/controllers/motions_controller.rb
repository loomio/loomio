class MotionsController < GroupBaseController
  load_and_authorize_resource :except => [:create, :show, :index]
  before_filter :authenticate_user!, :except => [:show, :index, :get_and_clear_new_activity]
  before_filter :check_group_read_permissions, :only => :show

  def create
    @motion = current_user.authored_motions.new(params[:motion])
    @group = GroupDecorator.new(@motion.group)
    authorize! :create, @motion
    if @motion.save
      flash[:success] = "Proposal successfully created."
      Event.new_motion!(@motion)
      redirect_to discussion_path(@motion.discussion)
    else
      flash[:warning] = "Proposal could not be created"
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
    flash[:success] = "Proposal deleted."
  end

  # CUSTOM ACTIONS

  def close_voting
    resource
    @motion.close_voting!
    Event.motion_closed!(@motion, current_user)
    redirect_to discussion_url(@motion.discussion, proposal: @motion)
  end

  def open_voting
    resource
    @motion.open_voting!
    redirect_to discussion_url(@motion.discussion)
  end

  def edit_outcome
    resource
    motion = Motion.find(params[:motion][:id])
    motion.set_outcome(params[:motion][:outcome])
    redirect_to discussion_url(motion.discussion, proposal: motion)
  end

  def get_and_clear_new_activity
    @motion = Motion.find(params[:id])
    @motion_activity = Integer(params[:motion_activity])
    @user = nil
    if user_signed_in?
      @user = current_user
      @user.update_motion_read_log(@motion)
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
