class GroupsController < BaseController
  before_filter :ensure_group_member,
                :except => [:new, :create, :index, :request_membership]
  def create
    build_resource
    @group.add_member! current_user
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
