class MotionsController < GroupBaseController
  load_and_authorize_resource :except => [:create, :show, :index]
  before_filter :authenticate_user!, :except => [:show, :index]
  before_filter :check_group_read_permissions, :only => :show

  def update
    resource
    update! { discussion_url(@motion.discussion_id) }
  end

  def create
    @motion = current_user.authored_motions.new(params[:motion])
    @group = GroupDecorator.new(@motion.group)
    authorize! :create, @motion
    if @motion.save
      flash[:success] = "Proposal successfully created."
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
        @closed_motions = @group.motions_closed.page(params[:page]).per(10)
        render :layout => false if request.xhr?
      end
    else
      authenticate_user!
      @closed_motions= current_user.motions_closed.page(params[:page]).per(10)
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

  def edit
    motion = Motion.find(params[:id])
    @group = GroupDecorator.new(motion.group)
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
