class DashboardController < BaseController
  def show
    @discussions_with_current_motion_voted_on = current_user.discussions_with_current_motion_voted_on
    @discussions_with_current_motion_not_voted_on = current_user.discussions_with_current_motion_not_voted_on
    @discussion = Discussion.new
    @groups = GroupDecorator.decorate(current_user.root_groups)
  end
end
