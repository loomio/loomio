class GroupsController < BaseController
  before_filter :ensure_group_member, :except => [:new, :create]
  def create
    build_resource
    @group.users << current_user
    create!
  end

  private
  def ensure_group_member
    unless resource.users.include? current_user
      redirect_to root_path
    end
  end
end
