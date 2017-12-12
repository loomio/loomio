class API::DiscussionsController < API::RestfulController
  after_action :track_visit, only: :show
  include UsesDiscussionReaders
  include UsesPolls
  include UsesFullSerializer

  def show
    load_and_authorize(:discussion)
    respond_with_resource
  end

  def index
    load_and_authorize(:group, optional: true)
    instantiate_collection { |collection| collection.sorted_by_importance }
    respond_with_collection
  end

  def dashboard
    raise CanCan::AccessDenied.new unless current_user.is_logged_in?
    instantiate_collection { |collection| collection_for_dashboard collection }
    respond_with_collection
  end

  def inbox
    raise CanCan::AccessDenied.new unless current_user.is_logged_in?
    instantiate_collection { |collection| collection_for_inbox collection }
    respond_with_collection scope: default_scope.merge(
      poll_cache:   Caches::Poll.new(parents: collection),
      reader_cache: Caches::DiscussionReader.new(user: current_user, parents: collection)
    )
  end

  def move
    @event = service.move discussion: load_resource, params: params, actor: current_user
    respond_with_resource
  end

  def mark_as_seen
    service.mark_as_seen discussion: load_resource, actor: current_user
    respond_with_resource
  end

  def mark_as_read
    service.mark_as_read(discussion: load_resource, params: params, actor: current_user)
    respond_with_resource
  end

  def dismiss
    service.dismiss discussion: load_resource, params: params, actor: current_user
    respond_with_resource
  end

  def pin
    service.pin discussion: load_resource, actor: current_user
    respond_with_resource
  end

  def set_volume
    update_reader volume: params[:volume]
  end

  private

  def track_visit
    VisitService.record(group: resource.group, visit: current_visit, user: current_user)
  end

  def accessible_records
    Queries::VisibleDiscussions.new(user: current_user, group_ids: @group && @group.id_and_subgroup_ids)
  end

  def update_reader(params = {})
    service.update_reader discussion: load_resource, params: params, actor: current_user
    respond_with_resource
  end

  def collection_for_dashboard(collection, filter: params[:filter])
    case filter
    when 'show_muted'         then collection.muted.sorted_by_latest_activity
    else                           collection.not_muted.sorted_by_importance
    end
  end

  def collection_for_inbox(collection)
    collection.recent.not_muted.unread.sorted_by_latest_activity.includes(:group, :author)
  end

end
