class DiscussionsController < GroupBaseController
  before_filter :check_group_read_permissions
  load_and_authorize_resource except: :show

  def new
    @discussion = Discussion.new(group: Group.find(params[:discussion][:group_id]))
  end

  def create
    group = Group.find(params[:discussion][:group_id])
    comment = params[:discussion][:comment]
    notify_group = params[:discussion][:notify_group_upon_creation]
    @discussion = Discussion.new(params[:discussion])
    @discussion.author = current_user
    @discussion.group = group
    if @discussion.save
      @discussion.add_comment(current_user, comment)
      unless notify_group.blank?
        DiscussionMailer.spam_new_discussion_created(@discussion)
      end
      flash[:success] = "Discussion sucessfully created."
      redirect_to @discussion
    else
      render action: :new
      flash[:error] = "Discussion could not be created."
    end
  end

  def show
    @discussion = Discussion.find(params[:id])
    @current_motion = @discussion.current_motion
    @vote = Vote.new
    @history = @discussion.history
    if (not params[:proposal]) && @current_motion
      @unique_votes = Vote.unique_votes(@current_motion)
      @votes_for_graph = @current_motion.votes_graph_ready
      @user_already_voted = @current_motion.user_has_voted?(current_user)
    else
      @selected_closed_motion = @discussion.closed_motion(params[:proposal])
      if @selected_closed_motion
        @votes_for_graph = @selected_closed_motion.votes_graph_ready
      end
    end

    if current_user
      current_user.update_discussion_read_log(@discussion)
    end
  end

  def add_comment
    comment = resource.add_comment(current_user, params[:comment])
    redirect_to discussion_path(resource.id)
  end

  def new_proposal
    @motion = Motion.new
    @motion.discussion = Discussion.find(params[:id])
    render template: 'motions/new'
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
