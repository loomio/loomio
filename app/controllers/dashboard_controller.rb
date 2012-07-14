class DashboardController < BaseController
  def show
    @motions_voted = current_user.motions_in_voting_phase_that_user_has_voted_on
    @motions_not_voted = current_user.motions_in_voting_phase_that_user_has_not_voted_on
    @motions_closed = current_user.motions_closed
    @discussions= current_user.discussions_sorted
    @groups = GroupDecorator.decorate(current_user.all_root_groups)
  end
end
