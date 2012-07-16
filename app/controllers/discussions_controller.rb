class DiscussionsController < GroupBaseController
  load_and_authorize_resource :except => [:show, :create]
  before_filter :check_group_read_permissions, :only => :show

  def new
    @group = GroupDecorator.new(Group.find(params[:discussion][:group_id]))
    @discussion = Discussion.new(group: @group)
  end

  def create
    @discussion = current_user.authored_discussions.new(params[:discussion])
    authorize! :create, @discussion
    if @discussion.save
      @discussion.add_comment(current_user, params[:discussion][:comment])
      if params[:discussion][:notify_group_upon_creation].to_i > 0
        DiscussionMailer.spam_new_discussion_created(@discussion)
      end
      Event.new_discussion!(@discussion)
      flash[:success] = "Discussion sucessfully created."
      redirect_to @discussion
    else
      render action: :new
      flash[:error] = "Discussion could not be created."
    end
  end

  def show
    @discussion = Discussion.find(params[:id])
    @group = GroupDecorator.new(@discussion.group)
    @current_motion = @discussion.current_motion
    @vote = Vote.new
    @history = @discussion.history
    if (not params[:proposal]) && @current_motion
      @unique_votes = Vote.unique_votes(@current_motion)
      @votes_for_graph = @current_motion.votes_graph_ready
      @user_already_voted = @current_motion.user_has_voted?(current_user)
    else
      @selected_motion = @discussion.closed_motion(params[:proposal])
      if @selected_motion
        @votes_for_graph = @selected_motion.votes_graph_ready
      end
    end

    if current_user
      current_user.update_discussion_read_log(@discussion)
    end
  end

  def add_comment
    comment = resource.add_comment(current_user, params[:comment])
    if comment.valid?
      Event.new_comment!(comment)
    else
      flash[:error] = "Comment could not be created."
    end
    redirect_to discussion_path(resource.id)
  end

  def new_proposal
    @motion = Motion.new
    discussion = Discussion.find(params[:id])
    @motion.discussion = discussion
    @group = GroupDecorator.new(discussion.group)
    render 'motions/new'
  end

  private

    def group
      @group ||= find_group
    end

    def find_group
      if (params[:id] && (params[:id] != "new"))
        Discussion.find(params[:id]).group
      elsif params[:discussion][:group_id]
        Group.find(params[:discussion][:group_id])
      end
    end

end
