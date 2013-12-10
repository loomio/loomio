class DiscussionsController < GroupBaseController
  include DiscussionsHelper

  before_filter :load_resource_by_key, :except => [:new, :create, :index, :update_version]
  authorize_resource                   :except => [:new, :create, :index, :add_comment]

  before_filter :authenticate_user!, :except => [:show, :index]
  after_filter :mark_as_read, only: :show

  rescue_from ActiveRecord::RecordNotFound do
    render 'application/display_error', locals: { message: t('error.not_found') }
  end

  def new
    @discussion = Discussion.new
    @uses_markdown = current_user.uses_markdown
    if params[:group_id]
      @discussion.group_id = params[:group_id]
    else
      @user_groups = current_user.groups.order('name') unless params[:group_id]
    end
  end

  def create
    build_discussion

    if DiscussionService.start_discussion(@discussion)
      flash[:success] = t("success.discussion_created")
      redirect_to @discussion
    else
      render action: :new
      flash[:error] = t("error.discussion_not_created")
    end
  end

  def destroy
    @discussion.delayed_destroy
    flash[:success] = t("success.discussion_deleted")
    redirect_to @discussion.group
  end

  def index
    if params[:group_id].present?
      @group = Group.find(params[:group_id])
      if cannot? :show, @group
        head 401
      else
        @no_discussions_exist = (@group.discussions.count == 0)
        @discussions = GroupDiscussionsViewer.
                       for(group: @group, user: current_user).
                       without_open_motions.
                       order_by_latest_comment.
                       page(params[:page]).per(10)
      end
    else
      authenticate_user!
      @no_discussions_exist = (current_user.discussions.count == 0)
      @discussions = Queries::VisibleDiscussions.
                     new(user: current_user).
                     without_open_motions.
                     order_by_latest_comment.
                     page(params[:page]).per(10)
    end
  end

  def show
    if @discussion.has_previous_versions?
      @last_collaborator = User.find(@discussion.originator.to_i)
    end
    @group = GroupDecorator.new(@discussion.group)
    @vote = Vote.new
    @current_motion = @discussion.current_motion
    assign_meta_data
    if params[:proposal]
      @displayed_motion = Motion.find(params[:proposal])
    elsif @current_motion
      @displayed_motion = @current_motion
    end

    if current_user
      @destination_groups = DiscussionMover.destination_groups(@discussion.group, current_user)
      @uses_markdown = current_user.uses_markdown?
      if @current_motion
        @current_motion.as_read_by(current_user).viewed!
      end
      @reader = @discussion.as_read_by(current_user)
      @activity = @discussion.activity.page(requested_or_first_unread_page).per(Discussion::PER_PAGE)
    else
      @activity = @discussion.activity.page(params[:page]).per(Discussion::PER_PAGE)
    end
  end

  def move
    origin = @discussion.group
    destination = Group.find(params[:discussion][:group_id])
    @discussion.group_id = params[:discussion][:group_id]
    if DiscussionMover.can_move?(current_user, origin, destination) &&
      @discussion.save!
      flash[:success] = "Discussion successfully moved."
    else
      flash[:error] = "Discussion could not be moved."
    end
    redirect_to @discussion
  end

  def add_comment
    build_comment
    if DiscussionService.add_comment(@comment)
      current_user.update_attributes(uses_markdown: params[:uses_markdown])
      @discussion.as_read_by(current_user).viewed!
    else
      head :ok and return
    end
  end

  def new_proposal
    if @discussion.current_motion
      redirect_to @discussion
      flash[:notice] = "A current proposal already exists for this discussion."
    else
      @motion = Motion.new
      @motion.discussion = @discussion
      @group = GroupDecorator.new(@discussion.group)
      render 'motions/new'
    end
  end

  def update_description
    @discussion.set_description!(params[:description], params[:description_uses_markdown], current_user)
    redirect_to @discussion
  end

  def edit_title
    @discussion.set_title!(params.require(:title), current_user)
    redirect_to @discussion
  end

  def show_description_history
    @originator = User.find @discussion.originator.to_i
    respond_to do |format|
      format.js
    end
  end

  def preview_version
    # assign live item if no version_id is passed
    if params[:version_id].nil?
      load_resource_by_key
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
    redirect_to @version.reify()
  end

  private

  def load_resource_by_key
    @discussion = Discussion.find_by_key(params[:key])
  end

  def build_comment
    @comment = Comment.new(body: params[:comment],
                           uses_markdown: params[:uses_markdown])

    attachment_ids = Array(params[:attachments]).map(&:to_i)

    @comment.discussion = @discussion
    @comment.author = current_user
    @comment.attachment_ids = attachment_ids
    @comment.attachments_count = attachment_ids.size
    @comment
  end

  def build_discussion
    @discussion = Discussion.new(permitted_params.discussion)
    @discussion.author = current_user
  end

  def mark_as_read
    if @reader and @activity and @activity.last
      @reader.viewed!(@activity.last.updated_at)
    end
  end

  def assign_meta_data
    if @group.privacy == 'public'
      @meta_title = @discussion.title
      @meta_description = @discussion.description
    end
  end

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
