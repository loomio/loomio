class GroupsController < BaseController
  before_filter :ensure_group_member, :except => [:new, :create, :index]
  def create
    build_resource
    @group.add_member! current_user
    create!
  end

  private
  def ensure_group_member
    unless resource.users.include? current_user
      redirect_to root_path
    end
  end
end
