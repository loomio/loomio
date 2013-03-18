class GroupsController < GroupBaseController
  load_and_authorize_resource except: :show
  before_filter :authenticate_user!, except: :show
  before_filter :check_group_read_permissions, :only => :show
  after_filter :store_location, :only => :show

  rescue_from ActiveRecord::RecordNotFound do
    render 'application/not_found', locals: { item: "group" }
  end

  def create
    @group = Group.new(params[:group])
    @group.creator = current_user
    if @group.save
      @group.add_admin! current_user
      @group.create_welcome_loomio
      flash[:success] = t("success.group_created")
      redirect_to @group
    else
      render 'groups/new'
    end
  end

  def show
    @group = GroupDecorator.new Group.find(params[:id])
    @subgroups = @group.subgroups.accessible_by(current_ability, :show)
    @discussions = Queries::VisibleDiscussions.for(@group, current_user)
    @discussion = Discussion.new(group_id: @group.id)
    @invited_users = @group.invited_users
    assign_meta_data
  end

  def edit
    @group = GroupDecorator.new(Group.find(params[:id]))
  end

  # CUSTOM CONTROLLER ACTIONS

  def archive
    @group = Group.find(params[:id])
    @group.archived_at = Time.current

    @group.subgroups.each do |subgroup|
      subgroup.archived_at = Time.current
      subgroup.save
    end

    if @group.save
      flash[:success] = t("success.group_archived")
      redirect_to dashboard_url
    else
      flash[:error] = t("error.group_not_archived")
      redirect_to :back
    end
  end

  def add_subgroup
    @parent = Group.find(params[:id])
    @subgroup = Group.new(:parent => @parent)
    @subgroup.members_invitable_by = @parent.members_invitable_by
  end

  # This method is only for subgroups
  def add_members
    params.each_key do |key|
      if key =~ /user_/
        user = User.find(key[5..-1])
        group.add_member!(user, current_user)
      end
    end
    flash[:success] = t("success.members_added")
    redirect_to group_url(group)
  end

  def request_membership
    if resource.users.include? current_user
      redirect_to group_url(resource)
    else
      @membership = Membership.new
    end
  end

  def new_motion
    @group = GroupDecorator.new Group.find(params[:id])
    @motion = Motion.new
  end

  def email_members
    @group = Group.find(params[:id])
    subject = params[:group_email_subject]
    body = params[:group_email_body]
    GroupMailer.delay.deliver_group_email(@group, current_user, subject, body)
    flash[:success] = t("success.emails_sending")
    redirect_to :back
  end

  def edit_description
    @group = Group.find(params[:id])
    @description = params[:description]
    @group.description = @description
    @group.save!
  end

  def get_members
    @users = group.users
    if (params[:pre].present?)
      @users = @users.select { |user| user.username =~ /#{params[:pre]}/ }
    end
    respond_to do |format|
      format.json { render 'groups/users' }
    end
  end

  def edit_privacy
    @group = Group.find(params[:id])
    @viewable_by = params[:viewable_by]
    @group.viewable_by = @viewable_by
    @group.save!
  end

  private

    def assign_meta_data
      if @group.viewable_by == :everyone
        @meta_title = @group.name
        @meta_description = @group.description
      end
    end

    def group
      resource
    end
end
