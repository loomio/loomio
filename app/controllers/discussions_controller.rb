class DiscussionsController < GroupBaseController
  include DiscussionsHelper

  before_filter :we_dont_serve_images_here_google_bot
  before_filter :authenticate_user!, :except => [:show, :index]
  before_filter :load_resource_by_key, except: [:new, :create, :index, :update_version]
  authorize_resource :except => [:new, :create, :index, :add_comment]

  skip_before_filter :boot_angular_ui, only: :print

  after_filter :mark_as_read, only: :show
  after_filter :track_visit, only: :show

  rescue_from ActiveRecord::RecordNotFound do
    render 'application/display_error', locals: { message: t('error.not_found') }
  end

  def new
    @discussion = Discussion.new user: current_user
    @discussion.uses_markdown = current_user.uses_markdown
    @group = Group.find_by_id params[:group_id]
    @discussion.group = @group
  end

  def edit
  end

  def update
    if DiscussionService.update(discussion: @discussion,
                                params: permitted_params.discussion,
                                actor: current_user)
      current_user.update_attributes(uses_markdown: @discussion.uses_markdown)
      flash[:notice] = t("success.discussion_updated")
      redirect_to @discussion
    else
      @user_groups = current_user.groups.order('name')
      render :edit
    end
  end

  def create
    build_discussion
    if DiscussionService.create(discussion: @discussion,
                                actor: current_user)
      current_user.update_attributes(uses_markdown: @discussion.uses_markdown)
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

  def show
    @group = @discussion.group

    if params[:proposal]
      @motion = @discussion.motions.find_by_key!(params[:proposal])
    else
      @motion = @discussion.most_recent_motion
    end

    if @motion
      @motion_reader = MotionReader.for(user: current_user_or_visitor, motion: @motion)
    end

    if can?(:move, @discussion)
      @destination_groups = current_user_or_visitor.groups.order(:full_name).uniq.reject { |g| g.id == @discussion.group_id }
    end

    @discussion_reader = DiscussionReader.for(user: current_user_or_visitor, discussion: @discussion)

    @closed_motions = @discussion.closed_motions

    @uses_markdown = current_user_or_visitor.uses_markdown?

    @activity = @discussion.items.page(requested_or_first_unread_page).per(Discussion::PER_PAGE)
    assign_meta_data

    @feed_url = discussion_url @discussion, format: :xml if @discussion.public?
  end

  def set_volume
    DiscussionReader.for(discussion: @discussion,
                         user: current_user).set_volume! params[:volume]
    redirect_to discussion_url @discussion
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
    if CommentService.create(comment: @comment, actor: current_user)
      if params[:uses_markdown]
        current_user.update_attributes(uses_markdown: params[:uses_markdown])
      end
      respond_to do |format|
        format.js
        format.html { redirect_to discussion_path(@discussion) }
      end
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
      @group = @discussion.group
      render 'motions/new'
    end
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
      version = PaperTrail::Version.find(params[:version_id])
      @discussion = version.reify
    end
    @originator = User.find @discussion.originator.to_i
    respond_to do |format|
      format.js { render :action => 'show_description_history' }
    end
  end

  def update_version
    @version = PaperTrail::Version.find(params[:version_id])
    @version.reify.save!
    redirect_to @version.reify()
  end

  def print
    @discussion = Discussion.find_by_key! params[:id]
    @group = @discussion.group
    if @discussion.motions.present?
      @motions = @discussion.motions.sort_by {|m| m.created_at }
    end
    @activity = @discussion.items if @discussion.items.present?
    render :layout => "print"
  end

  private

  def we_dont_serve_images_here_google_bot
    if request.format == :png
      render :text => 'Not Found', :status => '404'
    end
  end

  def load_resource_by_key
    @discussion ||= Discussion.published.find_by_key!(params[:id])
  end

  def build_discussion
    @discussion = Discussion.new(permitted_params.discussion)
    @discussion.author = current_user
  end

  def build_comment
    @comment = Comment.new(body: params[:comment],
                           uses_markdown: params[:uses_markdown].present?)

    attachment_ids = Array(params[:attachments]).map(&:to_i)

    @comment.discussion = @discussion
    @comment.author = current_user
    @comment.attachment_ids = attachment_ids
    @comment.attachments_count = attachment_ids.size
    @comment
  end

  def mark_as_read
    @discussion_reader.viewed! if @discussion_reader
    @motion_reader.viewed! if @motion_reader
  end

  def assign_meta_data
    if @group.is_visible_to_public?
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
