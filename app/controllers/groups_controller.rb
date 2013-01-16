class GroupsController < GroupBaseController
  load_and_authorize_resource except: :show
  before_filter :authenticate_user!, except: :show
  before_filter :check_group_read_permissions, :only => :show
  after_filter :store_location, :only => :show

  def create
    @group = Group.new(params[:group])
    @group.creator = current_user
    if @group.save
      @group.add_admin! current_user
      @group.create_welcome_loomio
      flash[:success] = "Group created successfully."
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
      flash[:success] = "Group archived successfully."
      redirect_to dashboard_url
    else
      flash[:error] = "Group could not be archived."
      redirect_to :back
    end
  end

  def add_subgroup
    @parent = Group.find(params[:id])
    @subgroup = Group.new(:parent => @parent)
    @subgroup.members_invitable_by = @parent.members_invitable_by
  end

  def add_members
    params.each_key do |key|
      if key =~ /user_/
        user = User.find(key[5..-1])
        group.add_member!(user, current_user)
      end
    end
    flash[:success] = "Members added to group."
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
    flash[:success] = "Emails sending."
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

    def group
      resource
    end
end
