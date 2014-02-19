class DashboardController < BaseController
  def show
    @discussions_with_open_motions = GroupDiscussionsViewer.for(group: @group, user: current_user).
                                                            with_open_motions.order('motions.closing_at ASC').
                                                            includes(:current_motion, :group)

    @discussions_without_open_motions = GroupDiscussionsViewer.for(group: @group, user: current_user).
                                                               without_open_motions.order('last_comment_at DESC').
                                                               includes(:current_motion, :group).
                                                               page(params[:page]).per(20)
    
    @discussions = [@discussions_with_open_motions.all + @discussions_without_open_motions].flatten

    @current_motions = @discussions_with_open_motions.map{|d| d.current_motion }

    @discussion_readers = DiscussionReader.where(user_id: current_user.id,
                                                  discussion_id: @discussions.map(&:id)).includes(:discussion => [:current_motion, :group])

    @discussion_reader_cache = DiscussionReaderCache.new(current_user, @discussion_readers)

    @motion_readers = MotionReader.where(user_id: current_user.id,
                                         motion_id: @current_motions.map(&:id) ).includes(:motion => :discussion)

    @motion_reader_cache = MotionReaderCache.new(current_user, @motion_readers)
    
    @last_votes = Vote.most_recent.where(user_id: current_user, motion_id: @current_motions.map(&:id))
    @last_vote_cache = VoteCache.new(current_user, @last_votes)
    
    # on discussion, preload author, current_motion -> author, votes
    # load discussion_readers for discussion, user and store in a hash key: discussion_id
    # preload motion_readers for user, discussions -> current_motions
  end
end
