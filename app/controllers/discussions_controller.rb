class DiscussionsController < GroupBaseController
  include DiscussionsHelper
  load_and_authorize_resource :except => [:new, :create, :index]
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
    current_user.update_attributes(uses_markdown: params[:discussion][:uses_markdown])

    @discussion = Discussion.new(permitted_params.discussion)
    @discussion.author = current_user

    authorize! :create, @discussion

    if @discussion.save
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
    if params[:comment].present? || params[:attachments].present?
      @discussion = Discussion.find(params[:id])
      @comment = @discussion.add_comment(current_user, params[:comment],
                                         uses_markdown: params[:uses_markdown], attachments: params[:attachments])
      current_user.update_attributes(uses_markdown: params[:uses_markdown])
      @discussion.as_read_by(current_user).viewed!
      unless request.xhr?
        redirect_to @discussion
      end
    else
      head :ok
    end
  end

  def new_proposal
    discussion = Discussion.find(params[:id])
    if discussion.current_motion
      redirect_to discussion
      flash[:notice] = "A current proposal already exists for this disscussion."
    else
      @motion = Motion.new
      @motion.discussion = discussion
      @group = GroupDecorator.new(discussion.group)
      render 'motions/new'
    end
  end

  def update_description
    @discussion = Discussion.find(params[:id])
    @discussion.set_description!(params[:description], params[:description_uses_markdown], current_user)
    redirect_to @discussion
  end

  def edit_title
    @discussion = Discussion.find(params[:id])
    @discussion.set_title!(params.require(:title), current_user)
    redirect_to @discussion
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
    redirect_to @version.reify()
  end

  private

  def mark_as_read
    if @reader and @activity and @activity.last
      @reader.viewed!(@activity.last.updated_at)
    end
  end

  def assign_meta_data
    if @group.viewable_by == 'everyone'
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
