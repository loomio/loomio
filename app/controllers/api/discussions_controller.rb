class Api::DiscussionsController < Api::RestfulController
  include UsesDiscussionReaders
  include UsesFullSerializer

  def index
    fetch_and_authorize(:group, optional: true)
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
    respond_with_collection
  end

  def move
    @event = service.move discussion: fetch_resource, params: params, actor: current_user
    respond_with_resource
  end

  def mark_as_read
    service.mark_as_read discussion: fetch_resource, params: params, actor: current_user
    respond_with_resource
  end

  def dismiss
    service.dismiss discussion: fetch_resource, params: params, actor: current_user
    respond_with_resource
  end

  def star
    service.update_reader discussion: fetch_resource, params: { starred: true }, actor: current_user
    respond_with_resource
  end

  def unstar
    service.update_reader discussion: fetch_resource, params: { starred: false }, actor: current_user
    respond_with_resource
  end

  def set_volume
    service.update_reader discussion: fetch_resource, params: { volume: params[:volume] }, actor: current_user
    respond_with_resource
  end

  private

  def accessible_records
    Queries::VisibleDiscussions.new(user: current_user, group_ids: @group && @group.id_and_subgroup_ids)
  end

  def collection_for_dashboard(collection, filter: params[:filter])
    case filter
    when 'show_participating' then collection.not_muted.participating.sorted_by_importance
    when 'show_muted'         then collection.muted.sorted_by_latest_activity
    else                           collection.not_muted.sorted_by_importance
    end
  end

  def collection_for_inbox(collection)
    collection.not_muted.unread.sorted_by_latest_activity
  end

end
