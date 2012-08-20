class DashboardController < BaseController
  def show
    @discussions_with_current_motion_voted_on = current_user.discussions_with_current_motion_voted_on
    @discussions_with_current_motion_not_voted_on = current_user.discussions_with_current_motion_not_voted_on
    @groups = GroupDecorator.decorate(current_user.all_root_groups)
  end
end
