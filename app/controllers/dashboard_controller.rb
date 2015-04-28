class DashboardController <  GroupBaseController
  include ApplicationHelper
  after_filter :clear_discussion_index_caches, only: :show

  def show
    @discussions = Queries::VisibleDiscussions.new(groups: current_user.groups, user: current_user).not_muted

    if sifting_unread?
      @discussions = @discussions.unread
    end

    @discussions = @discussions.joined_to_current_motion.
                                preload(:current_motion, {group: :parent}).
                                order_by_closing_soon_then_latest_activity.
                                page(params[:page]).per(20)
    build_discussion_index_caches

    # on discussion, preload author, current_motion -> author, votes
    # load discussion_readers for discussion, user and store in a hash key: discussion_id
    # preload motion_readers for user, discussions -> current_motions
  end
end
