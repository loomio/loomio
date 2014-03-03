class DiscussionsController < GroupBaseController
  include DiscussionsHelper

  before_filter :authenticate_user!, :except => [:show, :index]
  before_filter :load_resource_by_key, except: [:new, :create, :index, :update_version]
  authorize_resource :except => [:new, :create, :index, :add_comment]

  after_filter :mark_as_read, only: :show

  rescue_from ActiveRecord::RecordNotFound do
    render 'application/display_error', locals: { message: t('error.not_found') }
  end

  def new
    @discussion = Discussion.new
    @discussion.uses_markdown = current_user.uses_markdown
    @group = Group.find_by_id params[:group_id]
    @discussion.group = @group
    @user_groups = current_user.groups.order('name')
  end

  def edit
  end

  def update
    if DiscussionService.edit_discussion(current_user, permitted_params.discussion, @discussion)
      flash[:notice] = 'Discussion was successfully updated.'
      redirect_to @discussion
    else
      @user_groups = current_user.groups.order('name')
      render :edit
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
    @group = GroupDecorator.new(@discussion.group)

    if params[:proposal]
      @motion = @discussion.motions.find(params[:proposal])
    else
      @motion = @discussion.most_recent_motion
    end

    if @motion
      @motion_reader = MotionReader.for(user: current_user_or_visitor, motion: @motion)
    end

    @discussion_reader = DiscussionReader.for(user: current_user_or_visitor, discussion: @discussion)

    @closed_motions = @discussion.closed_motions

    @uses_markdown = current_user_or_visitor.uses_markdown?

    @activity = @discussion.activity.page(requested_or_first_unread_page).per(Discussion::PER_PAGE)
    assign_meta_data
  end

  def move
    destination_group = Group.find params[:destination_group_id]

    discussion_mover = MoveDiscussionService.new(discussion: @discussion,
                                                 destination_group: destination_group,
                                                 user: current_user)
    if discussion_mover.move!
      flash[:notice] = t(:'success.discussion_moved', group_name: destination_group.name)
    else
      flash[:alert] = t(:'error.discussion_not_moved', group_name: destination_group.name)
    end

    redirect_to @discussion
  end

  def add_comment
    build_comment
    if DiscussionService.add_comment(@comment)
      current_user.update_attributes(uses_markdown: params[:uses_markdown])
      DiscussionReader.for(user: current_user, discussion: @discussion).viewed!
    else
      head :ok and return
    end
  end

  def new_proposal
    if @discussion.current_motion
      redirect_to @discussion
      flash[:notice] = "A current proposal already exists for this disscussion."
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
    if params[:version_id].present?
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
    @discussion ||= Discussion.published.find_by_key!(params[:id])
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
    if @activity and @activity.last
      @discussion_reader.viewed!(@activity.last.updated_at)
      @motion_reader.viewed! if @motion_reader
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
      Discussion.published.find(params[:id]).group
    elsif params[:discussion][:group_id]
      Group.find(params[:discussion][:group_id])
    end
  end
end
