class DashboardController < BaseController
  def show
    @discussions = Queries::VisibleDiscussions.new(user: current_user)
  end

  def raise_error_raincheck
    # This action is nessasary to test the functionality of
    # our error rainchecks functionality
    raise error
  end
end
