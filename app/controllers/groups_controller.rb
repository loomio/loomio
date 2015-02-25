class GroupsController < GroupBaseController
  include ApplicationHelper
  before_filter :authenticate_user!, except: :show

  before_filter :load_group, :except => [:create, :new]
  authorize_resource except: [:create, :members_autocomplete]

  before_filter :ensure_group_is_setup, only: :show
  before_filter :assign_meta_data, only: :show

  rescue_from ActiveRecord::RecordNotFound do
    render 'application/display_error', locals: { message: t('error.group_private_or_not_found') }
  end

  #for new subgroup form
  def add_subgroup
    parent = Group.published.find_by(key: params[:id])
    @subgroup = Group.new(parent: parent,
                          is_visible_to_public: parent.is_visible_to_public,
                          discussion_privacy_options: parent.discussion_privacy_options)
    @subgroup.members_can_add_members = parent.members_can_add_members
  end

  def join
    MembershipService.join_group(group: @group, user: current_user)
    redirect_to @group, notice: t(:you_have_joined_group, group_name: @group.name)
  end

  def create
    @group = Group.new(permitted_params.group)
    authorize!(:create, @group)
    if @group.save
      @group.mark_as_setup!
      @group.add_admin! current_user
      @group.creator = current_user
      Measurement.increment('groups.create.success')
      flash[:success] = t("success.group_created")
      redirect_to @group
    elsif @group.is_subgroup?
      @subgroup = @group
      render 'groups/add_subgroup'
    else
      Measurement.increment('groups.create.error')
      render 'new'
    end
  end

  def new
    @group = Group.new
    @group.payment_plan = 'undetermined'
  end

  def update
    if @group.update_attributes(permitted_params.group)

      if @group.private_discussions_only?
        @group.discussions.update_all(private: true)
      end

      if @group.public_discussions_only?
        @group.discussions.update_all(private: false)
      end

      Measurement.increment('groups.update.success')
      flash[:notice] = 'Group was successfully updated.'
      redirect_to @group
    else
      Measurement.increment('groups.update.error')
      render :edit
    end
  end

  def show
    @discussion = Discussion.new(group_id: @group.id)

    @discussions = GroupDiscussionsViewer.for(group: @group, user: current_user)

    if sifting_unread?
      @discussions = @discussions.unread
    end

    if sifting_followed?
      @discussions = @discussions.following
    end

    @discussions = @discussions.joined_to_current_motion.
                                preload(:current_motion, {:group => :parent}).
                                order_by_closing_soon_then_latest_activity.
                                page(params[:page]).per(20)

    @closed_motions = Queries::VisibleMotions.new(user: current_user, groups: @group).order('closed_at desc')
    @feed_url = group_url @group, format: :xml if @group.is_visible_to_public?

    build_discussion_index_caches
  end

  def edit
  end

  def archive
    @group.archive!
    flash[:success] = t("success.group_archived")
    redirect_to dashboard_path
  end

  def hide_next_steps
    @group.update_attribute(:next_steps_completed, true)
  end

  def email_members
    subject = params[:group_email_subject]
    body = params[:group_email_body]
    GroupMailer.deliver_group_email(@group, current_user, subject, body)
    Measurement.measure('groups.email_members.size', @group.members.size)
    flash[:success] = t("success.emails_sending")
    redirect_to @group
  end

  def members_autocomplete
    users = @group.users.where('username ilike :term or name ilike :term ', {term: "%#{params[:q]}%"})
    render json: users.map{|u| {name: "#{u.name} #{u.username}", username: u.username, real_name: u.name} }, root: false  
  end

  def follow
    membership = @group.membership_for(current_user)
    membership.follow_by_default!
    redirect_to @group
  end

  def unfollow
    membership = @group.membership_for(current_user)
    membership.dont_follow_by_default!
    redirect_to @group
  end

  private
    def ensure_group_is_setup
      if user_signed_in? && @group.admins.include?(current_user)
        unless @group.is_setup? || @group.is_subgroup?
          redirect_to setup_group_path(@group)
        end
      end
    end

    def assign_meta_data
      if @group.is_visible_to_public?
        @meta_title = @group.name
        @meta_description = @group.description
      end
    end
end
