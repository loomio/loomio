class Admin::GroupsController < BaseController
  def index
    if current_user.admin?
      @groups = Group.all
    else
      redirect_to groups_url
    end
  end
end
