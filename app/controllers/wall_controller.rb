class WallController < BaseController
  def index
    # discussions that had activity in the last 24 hours
    groups = current_user.inbox_groups
    @discussions = Queries::VisibleDiscussions.new(user: current_user,
                                                   groups: groups)
  end
end
