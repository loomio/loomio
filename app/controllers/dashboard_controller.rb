class DashboardController <  GroupBaseController
  def show
    @discussions_with_open_motions = GroupDiscussionsViewer.for(user: current_user).
                                                            with_open_motions.
                                                            order('motions.closing_at ASC').
                                                            preload({:current_motion => :discussion}, {:group => :parent})

    @discussions_without_open_motions = GroupDiscussionsViewer.for(user: current_user).
                                                               without_open_motions.
                                                               order('last_comment_at DESC').
                                                               preload(:current_motion, {:group => :parent}).
                                                               page(params[:page]).per(20)
    build_discussion_index_caches

    # on discussion, preload author, current_motion -> author, votes
    # load discussion_readers for discussion, user and store in a hash key: discussion_id
    # preload motion_readers for user, discussions -> current_motions
  end
end
