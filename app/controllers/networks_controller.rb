class NetworksController < BaseController
  before_filter :authenticate_user!, except: [:show, :groups]
  after_filter :clear_discussion_index_caches, only: :show

  def show
    @network = Network.friendly.find params[:id]
    @discussions = Queries::VisibleDiscussions.new(user: current_user, groups: @network.groups)
    @discussions = @discussions.joined_to_current_motion.
                                preload(:current_motion, {:group => :parent}).
                                order_by_closing_soon_then_latest_activity.
                                page(params[:page]).per(20)
    build_discussion_index_caches
  end

  def groups
    @network = Network.friendly.find params[:id]
    @groups = @network.groups.order('memberships_count desc')
  end

  private

  def build_discussion_index_caches
    @current_motion_ids = @discussions.map(&:current_motion).compact.map(&:id)

    if current_user
      @motion_readers = MotionReader.where(user_id: current_user.id,
                                           motion_id: @current_motion_ids ).includes(:motion)
      @last_votes = Vote.most_recent.where(user_id: current_user, motion_id: @current_motion_ids)
    else
      @motion_readers = []
      @last_votes = []
    end

    @discussion_reader_cache = DiscussionReaderCache.new(user: current_user, discussions: @discussions)
    @motion_reader_cache = MotionReaderCache.new(current_user, @motion_readers)

    @last_vote_cache = VoteCache.new(current_user, @last_votes)
  end

  def clear_discussion_index_caches
    @discussion_reader_cache.clear
    @motion_reader_cache.clear
    @last_vote_cache.clear
  end
end
