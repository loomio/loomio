class API::DiscussionsController < API::RestfulController
  load_and_authorize_resource only: [:show, :mark_as_read, :move]
  load_resource only: [:create, :update, :star, :unstar, :set_volume]
  include UsesDiscussionReaders

  def index
    load_and_authorize(:group) if params[:group_id] || params[:group_key]
    instantiate_collection { |collection| collection.sorted_by_importance }
    respond_with_collection
  end

  def dashboard
    instantiate_collection { |collection| collection_for_dashboard collection }
    respond_with_collection
  end

  def inbox
    instantiate_collection { |collection| collection_for_inbox collection }
    respond_with_collection
  end

  def move
    service.move discussion: resource, params: params, actor: current_user
    respond_with_resource
  end

  def mark_as_read
    service.mark_as_read discussion: resource, params: params, actor: current_user
    respond_with_resource
  end

  def star
    service.update_reader discussion: resource, params: { starred: true }, actor: current_user
    respond_with_resource
  end

  def unstar
    service.update_reader discussion: resource, params: { starred: false }, actor: current_user
    respond_with_resource
  end

  def set_volume
    service.update_reader discussion: resource, params: { volume: params[:volume] }, actor: current_user
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
