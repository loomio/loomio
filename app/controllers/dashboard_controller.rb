class DashboardController < BaseController
  def show
    @discussion = Discussion.new
    @groups = GroupDecorator.decorate(current_user.root_groups)
  end
end
