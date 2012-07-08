class DashboardController < BaseController
  def show
    @motions_voted = current_user.motions_voted
    @motions_not_voted = current_user.motions_not_voted
    @motions_closed = current_user.motions_closed
    @groups = GroupDecorator.decorate(current_user.all_root_groups)
  end
end
