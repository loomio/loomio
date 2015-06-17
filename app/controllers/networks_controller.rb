class NetworksController < BaseController
  include DiscussionIndexCacheHelper
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

end
