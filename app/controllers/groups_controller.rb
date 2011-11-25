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
  end

  private
  def ensure_group_member
    unless resource.users.include? current_user
      redirect_to request_membership_group_path
    end
  end
end
