class DiscussionsController < GroupBaseController
  load_and_authorize_resource :except => [:show, :new, :create, :index]
  before_filter :authenticate_user!, :except => [:show, :index]
  before_filter :check_group_read_permissions, :only => :show
  after_filter :store_location, :only => :show

  def new
    @discussion = Discussion.new
    if params[:group_id]
      @discussion.group_id = params[:group_id]
    else
      @user_groups = current_user.groups.order('name') unless params[:group_id]
    end
  end

  def create
    @discussion = current_user.authored_discussions.new(params[:discussion])
    authorize! :create, @discussion
    if @discussion.save
      flash[:success] = "Discussion sucessfully created."
      redirect_to @discussion
    else
      render action: :new
      flash[:error] = "Discussion could not be created."
    end
  end

  def index
    if params[:group_id].present?
      @group = Group.find(params[:group_id])
      if cannot? :show, @group
        head 401
      else
        @discussions = Queries::VisibleDiscussions.for(@group, current_user).
                       without_current_motions.page(params[:page]).per(10)
        @no_discussions_exist = (@group.discussions.count == 0)
        render :layout => false if request.xhr?
      end
    else
      authenticate_user!
      @discussions = current_user.discussions_sorted.page(params[:page]).per(10)
      @no_discussions_exist = (current_user.discussions.count == 0)
      render :layout => false if request.xhr?
    end
  end

  def show
    @discussion = Discussion.find(params[:id])
    @last_collaborator = User.find @discussion.originator.to_i if @discussion.has_previous_versions?
    @group = GroupDecorator.new(@discussion.group)
    @current_motion = @discussion.current_motion
    @vote = Vote.new
    @activity = @discussion.activity
    @uses_markdown = current_user.uses_markdown?
    if (not params[:proposal])
      if @current_motion
        @unique_votes = Vote.unique_votes(@current_motion)
        @votes_for_graph = @current_motion.votes_graph_ready
        @user_already_voted = @current_motion.user_has_voted?(current_user)
      end
    else
      @selected_motion = Motion.find(params[:proposal])
      @user_already_voted = @selected_motion.user_has_voted?(current_user)
      @votes_for_graph = @selected_motion.votes_graph_ready
    end

    if current_user
      current_user.update_motion_read_log(@current_motion) if @current_motion
      current_user.update_discussion_read_log(@discussion)
    end
  end

  def add_comment
    @discussion = Discussion.find(params[:id])
    comment = resource.add_comment(current_user, params[:comment])
    unless comment.valid?
      flash[:error] = "Comment could not be created."
      redirect_to discussion_path(resource.id)
    end
    respond_to do |format|
      format.js
    end
  end

  def new_proposal
    @motion = Motion.new
    discussion = Discussion.find(params[:id])
    @motion.discussion = discussion
    @group = GroupDecorator.new(discussion.group)
    render 'motions/new'
  end

  def edit_description
    @discussion = Discussion.find(params[:id])
    @discussion.set_description!(params[:description], current_user)
    @last_collaborator = User.find @discussion.originator.to_i
    respond_to do |format|
      format.js { render :action => 'update_version' }
    end
  end

  def edit_title
    @discussion = Discussion.find(params[:id])
    @discussion.set_title!(params[:title], current_user)
  end

  def show_description_history
    @discussion = Discussion.find(params[:id])
    @originator = User.find @discussion.originator.to_i
    respond_to do |format|
      format.js
    end
  end

  def preview_version
    # assign live item if no version_id is passed
    if params[:version_id].nil?
      @discussion = Discussion.find(params[:id])
    else
      version = Version.find(params[:version_id])
      @discussion = version.reify
    end
    @originator = User.find @discussion.originator.to_i
    respond_to do |format|
      format.js { render :action => 'show_description_history' }
    end
  end

  def update_version
    @version = Version.find(params[:version_id])
    @version.reify.save!
    @discussion = @version.item
    @last_collaborator = User.find @discussion.originator.to_i
    respond_to do |format|
      format.js
    end
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
