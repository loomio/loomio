class GroupsController < GroupBaseController
  load_and_authorize_resource except: :show
  before_filter :authenticate_user!, except: :show
  before_filter :check_group_read_permissions, :only => :show

  def create
    @group = Group.new(params[:group])
    @group.creator = current_user
    if @group.save
      @group.add_admin! current_user
      flash[:success] = "Group created successfully."
      redirect_to @group
    else
      redirect_to :back
    end
  end

  def show
    @group = GroupDecorator.new(Group.find(params[:id]))
    @subgroups = @group.subgroups.accessible_by(current_ability, :show)
    @motions_not_voted = []
    if current_user
      @discussions_with_current_motion_voted_on = @group.discussions_with_current_motion_voted_on(current_user)
      @discussions_with_current_motion_not_voted_on = @group.discussions_with_current_motion_not_voted_on(current_user)
      @discussion = Discussion.new(group_id: @group.id)
    else
      @discussions_with_current_motion_voted_on = @group.discussions_with_current_motion(current_user)
      @discussions_with_current_motion_not_voted_on = []
    end
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
        membership = group.add_member!(user, current_user)
        Event.user_added_to_group!(membership)
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

  def create_motion
    @group = Group.find(params[:id])
    @discussion = current_user.authored_discussions.create!(group_id: @group.id,
                  title: params[:motion][:name])
    @motion = @discussion.motions.new(params[:motion])
    @motion.author = current_user
    if @motion.save
      flash[:success] = "Proposal has been created."
      Event.new_motion!(@motion)
      redirect_to @discussion
    else
      flash[:error] = "Proposal could not be created."
      redirect_to :back
    end
  end

  def email_members
    @group = Group.find(params[:id])
    subject = params[:group_email_subject]
    body = params[:group_email_body]
    GroupMailer.deliver_group_email(@group, current_user, subject, body)
    flash[:success] = "Email sent."
    redirect_to :back
  end

  def edit_description
    @group = Group.find(params[:id])
    @description = params[:description]
    @group.description = @description
    @group.save!
  end

  private

    def group
      resource
    end
end
