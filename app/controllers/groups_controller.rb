class GroupsController < BaseController
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
    @groups = []
    memberships = Membership.where(
      "user_id = ? AND (access_level = 'member' OR access_level = 'admin')", 
      current_user.id)
    memberships.each do |m|
      @groups << m.group
    end
    @group_requests = []
    memberships = Membership.where("user_id = ? AND access_level = 'request'", 
                                   current_user.id)
    memberships.each do |m|
      @group_requests << m.group
    end
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
  def ensure_group_member
    unless resource.users.include? current_user
      if resource.requested_users_include?(current_user)
        flash[:notice] = "Cannot access group yet... waiting for membership approval."
        redirect_to groups_url
      else
        redirect_to request_membership_group_url
      end
    end
  end
end
