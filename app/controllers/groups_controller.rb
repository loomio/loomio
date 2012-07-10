class GroupsController < GroupBaseController
  load_and_authorize_resource except: :show
  before_filter :check_group_read_permissions, :only => :show

  def create
    @group = Group.new(params[:group])
    @group.creator_id = current_user.id
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
    if current_user
      @motions_voted = current_user.group_motions_not_voted(@group)
      @motions_not_voted = current_user.group_motions_not_voted(@group)
    else
      @motions_voted = @group.motions_voting
    end
    @motions_closed = @group.motions_closed
  end

  def edit
    @group = GroupDecorator.new(Group.find(params[:id]))
  end

  # CUSTOM CONTROLLER ACTIONS

  def add_subgroup
    @parent = Group.find(params[:id])
    @subgroup = Group.new(:parent => @parent)
    @subgroup.members_invitable_by = @parent.members_invitable_by
  end

  def add_members
    params.each_key do |key|
      if key =~ /user_/
        user = User.find(key[5..-1])
        group.add_member!(user)
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

  private

    def group
      resource
    end
end
