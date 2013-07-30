class DashboardController < BaseController
  def show
    @discussions = Queries::VisibleDiscussions.new(user: current_user)
  end
end
