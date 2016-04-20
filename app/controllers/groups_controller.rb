class GroupsController < GroupBaseController
  include ApplicationHelper
  include DiscussionIndexCacheHelper
  before_filter :authenticate_user!, except: :show
  skip_before_filter :boot_angular_ui, only: :export

  before_filter :load_group, :except => [:create, :new]
  authorize_resource except: [:create, :members_autocomplete]

  before_filter :assign_meta_data, only: :show
  after_filter :clear_discussion_index_caches, only: :show
  after_filter :track_visit, only: :show

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
    MembershipService.join_group(group: @group, actor: current_user)
    redirect_to @group, notice: t(:you_have_joined_group, group_name: @group.name)
  end

  def export
    #@group
    @group_ids = [@group.id, @group.subgroup_ids].flatten
    @groups = Group.where(id: @group_ids)

    @group_fields = %w[id key name description created_at]

    @memberships = Membership.where(group_id: @group_ids).chronologically
    @membership_fields = %w[group_id user_id user_name admin created_at]

    @invitations = Invitation.where(invitable_id: @group_ids, invitable_type: 'Group').chronologically
    @invitation_fields = %w[id invitable_id recipient_email inviter_name accepted_at]

    @discussions = Discussion.where(group_id: @group_ids).chronologically
    @discussion_fields = %w[id group_id author_id author_name title description created_at]

    @comments = Comment.joins(:discussion => :group).where('discussions.group_id' => @group_ids).chronologically
    @comment_fields = %w[id group_id discussion_id author_id discussion_title author_name body created_at]

    @proposals = Motion.joins(:discussion => :group).where('discussions.group_id' => @group_ids).chronologically
    @proposal_fields = %w[id group_id discussion_id author_id discussion_title author_name proposal_title description created_at closed_at outcome yes_votes_count no_votes_count abstain_votes_count block_votes_count closing_at voters_count members_count votes_count]

    @votes = Vote.joins(:motion => {:discussion => :group}).where('discussions.group_id' => @group_ids).chronologically
    @vote_fields = %w[id group_id discussion_id motion_id user_id discussion_title motion_name user_name position statement created_at]

    @field_names = {'motion_name' => 'proposal_title', 'invitable_id' => 'group_id', 'motion_id' => 'proposal_id'}

    if request[:format] == 'xls'
      render content_type: 'application/vnd.ms-excel', layout: false
    else
      render layout: false
    end
  end


  # only to be used to create subgroups
  def create
    @group = Group.new(permitted_params.group)
    authorize!(:create, @group)
    if @group.save
      @group.add_admin! current_user
      @group.creator = current_user
      flash[:success] = t("success.group_created")
      redirect_to @group
    else
      @subgroup = @group
      render 'groups/add_subgroup'
    end
  end

  def update
    if GroupService.update(group: @group, params: permitted_params.group, actor: current_user)
      flash[:notice] = 'Group was successfully updated.'
      redirect_to @group
    else
      render :edit
    end
  end

  def show
    @membership = @group.membership_for(current_user) if user_signed_in?
    @discussion = Discussion.new(group_id: @group.id)

    @visible_groups = VisibleGroupsQuery.expand(group: @group, user: current_user)
    @discussions = Queries::VisibleDiscussions.new(groups: @visible_groups, user: current_user)

    if sifting_unread?
      @discussions = @discussions.unread
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
    flash[:success] = t("success.emails_sending")
    redirect_to @group
  end

  def members_autocomplete
    users = @group.users.where('username ilike :term or name ilike :term ', {term: "%#{params[:q]}%"})
    render json: users.map{|u| {name: "#{u.name} #{u.username}", username: u.username, real_name: u.name} }, root: false
  end

  def set_volume
    membership = @group.membership_for(current_user)
    membership.set_volume! params[:volume]
    redirect_to @group
  end


  private

  def metadata
    @metadata ||= Metadata::GroupSerializer.new(load_group).as_json
  end

    def assign_meta_data
      if @group.is_visible_to_public?
        @meta_title = @group.name
        @meta_description = @group.description
      end
    end
end
