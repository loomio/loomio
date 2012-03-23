class GroupsController < GroupBaseController
  before_filter :ensure_group_member,
                :except => [:new, :create, :index, :request_membership]

  def create
    build_resource
    @group.add_admin! current_user
    create!
  end

  def index
    @groups = current_user.groups
    @group_requests = current_user.group_requests
  end


  # CUSTOM CONTROLLER ACTIONS

  def invite_member
    @group = Group.find(params[:id])
    @user = User.new
  end

  def request_membership
    @group = Group.find(params[:id])
    @membership = Membership.new
  end

  def add_user_tag
    @group = Group.find(params[:id])
    @user = User.find(params[:user_id])
    @new_tags = @user.group_tags.join(",") + "," + params[:tag]
    @group.tag @user, with: @new_tags, on: :group_tags
    #TODO remove
    redirect_to groups_url
  end

  def delete_user_tag
    @group = Group.find(params[:id])
    @user = User.find(params[:user_id])
    @new_tags = @user.group_tags.join(",").gsub(params[:tag], "")
    @group.tag @user, with: @new_tags, on: :group_tags
    #TODO remove
    redirect_to groups_url
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

  def group_tags
    @group = Group.find(params[:id])
    @tags = @group.owned_tags.where("tags.name LIKE ?", "%#{params[:q]}%")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tags.collect {|tag| {:id => tag.id, :name => tag.name } } }
    end
  end

  private

    def group
      resource
    end
end
