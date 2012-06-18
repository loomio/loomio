class GroupsController < GroupBaseController
  load_and_authorize_resource except: :show
  before_filter :check_group_read_permissions, :only => :show

  def create
    @group = Group.new(params[:group])
    if @group.save
      @group.add_admin! current_user
      flash[:success] = "Group created successfully."
      redirect_to @group
    else
      redirect_to :back
    end
  end

  def show
    @discussions_awaiting_vote = @group.discussions_awaiting_user_vote(current_user) if current_user
    @discussions_active = @group.active_discussions(current_user)
    @discussions_inactive = @group.inactive_discussions(current_user)
    @group = GroupDecorator.new(Group.find(params[:id]))
    @subgroups = @group.subgroups.select do |group|
      can? :show, group
    end
  end

  # CUSTOM CONTROLLER ACTIONS

  def add_subgroup
    @parent = Group.find(params[:group_id])
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
