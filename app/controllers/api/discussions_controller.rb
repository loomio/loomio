class API::DiscussionsController < API::RestfulController
  load_and_authorize_resource only: [:show, :mark_as_read, :set_volume]
  load_resource only: [:create, :update, :mark_as_read]

  def dashboard
    instantiate_collection { |collection| collection_for_dashboard collection }
    respond_with_collection
  end

  def inbox
    instantiate_collection { |collection| collection_for_inbox collection }
    respond_with_collection
  end

  def mark_as_read
    DiscussionReader.for(user: current_user, discussion: resource).viewed! (discussion_event || resource).created_at
    respond_with_resource
  end

  private

  def visible_records
    Queries::VisibleDiscussions.new(user: current_user, groups: visible_groups)
  end

  def visible_groups
    load_and_authorize :group if params[:group_id] || params[:group_key]
    Array(@group).presence || current_user.groups
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

  def discussion_event
    Event.where(discussion_id: resource.id, sequence_id: params[:sequence_id]).first
  end

end
