class DashboardController < BaseController
  def show
    @motions = current_user.motions
    @motions_discussing = current_user.motions_discussing
    @motions_voting = current_user.motions_voting
    @motions_voted = current_user.motions_voting.that_user_has_voted_on(current_user)
    @motions_closed = current_user.motions_closed
    @groups = current_user.groups
  end
end
