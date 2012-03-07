class GroupsController < GroupBaseController
  before_filter :ensure_group_member,
                :except => [:new, :create, :index, :request_membership]
  def create
    build_resource
    @group.add_admin! current_user
    create!
  end

  def request_membership
    @group = Group.find(params[:id])
    @membership = Membership.new
  end

  def index
    @groups = current_user.groups
    @group_requests = current_user.group_requests
  end

  def tag_user
    @group = Group.find(params[:id])
    @users = @group.users

    if request.post?
      @user = @group.users.find(params[:user])
      @group.tag @user, with: params[:tag], on: :group_tags
    end

    @tags = @group.owned_tags
  end

  private

    def group
      resource
    end
end
