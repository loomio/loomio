class DashboardController < BaseController
  def show
    @discussions_with_current_motion_voted_on = current_user.discussions_with_current_motion_voted_on
    @discussions_with_current_motion_not_voted_on = current_user.discussions_with_current_motion_not_voted_on
  end

  def raise_error_raincheck
    # This action is nessasary to test the functionality of
    # our error rainchecks functionality
    raise error
  end
end
