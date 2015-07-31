class API::DiscussionsController < API::RestfulController
  load_and_authorize_resource only: [:show, :mark_as_read, :set_volume]
  load_resource only: [:create, :update]

  def dashboard
    instantiate_collection { |collection| filter_collection collection }
    respond_with_collection scope: { visible_on_dashboard: true }, serializer: DiscussionWrapperSerializer, root: 'discussion_wrappers'
  end

  def index
    load_and_authorize :group if params[:group_id] || params[:group_key]
    instantiate_collection
    respond_with_collection serializer: DiscussionWrapperSerializer, root: 'discussion_wrappers'
  end

  private

  def visible_records
    Queries::VisibleDiscussions.new(user: current_user, groups: visible_groups).sorted_by_latest_activity
  end

  def visible_groups
    Array(@group).presence || current_user.groups
  end

  def filter_collection(collection, filter = params[:filter])
    case filter
    when 'show_proposals'     then collection.not_muted.with_active_motions
    when 'show_participating' then collection.not_muted.participating
    when 'show_starred'       then collection.not_muted.starred
    when 'show_muted'         then collection.muted
    when 'show_unread'        then collection.not_muted.unread
    else                           collection.not_muted
    end
  end

  def collection=(value)
    @discussions = DiscussionWrapper.new_collection user: current_user, discussions: value
  end
end
