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

  def showall
    index!
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
