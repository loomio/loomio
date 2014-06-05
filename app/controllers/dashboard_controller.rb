class DashboardController <  GroupBaseController
  def show
    @discussions = GroupDiscussionsViewer.for(user: current_user).
                                          joined_to_current_motion.
                                          preload(:current_motion, {:group => :parent}).
                                          order('motions.closing_at ASC, last_comment_at DESC').
                                          page(params[:page]).per(20)
    build_discussion_index_caches

    # on discussion, preload author, current_motion -> author, votes
    # load discussion_readers for discussion, user and store in a hash key: discussion_id
    # preload motion_readers for user, discussions -> current_motions
  end
end
