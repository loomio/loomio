class API::DiscussionsController < API::RestfulController
  include UsesDiscussionReaders
  include UsesPolls
  include UsesDiscussionEvents

  def create
    instantiate_resource
    if resource_params[:forked_event_ids] && resource_params[:forked_event_ids].any?
      EventService.move_comments(discussion: create_action.discussion, params: resource_params, actor: current_user)
    else
      create_action
    end
    respond_with_resource
  end

  def show
    load_and_authorize(:discussion)
    accept_pending_membership
    respond_with_resource
  end

  def index
    load_and_authorize(:group, optional: true)
    instantiate_collection { |collection| collection_for_index collection }
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

  def search
    load_and_authorize(:group)
    instantiate_collection { |collection| collection.search_for(params.require(:q)) }
    respond_with_collection
  end

  def move
    @event = service.move discussion: load_resource, params: params, actor: current_user
    respond_with_resource
  end

  def mark_as_seen
    service.mark_as_seen discussion: load_resource, actor: current_user
    respond_ok
  end

  def mark_as_read
    service.mark_as_read(discussion: load_resource, params: params, actor: current_user)
    respond_ok
  end

  def dismiss
    service.dismiss discussion: load_resource, params: params, actor: current_user
    respond_with_resource
  end

  def recall
    service.recall discussion: load_resource, params: params, actor: current_user
    respond_with_resource
  end

  def close
    @event = service.close discussion: load_resource, actor: current_user
    respond_with_resource
  end

  def reopen
    @event = service.reopen discussion: load_resource, actor: current_user
    respond_with_resource
  end

  def fork
    @event = service.fork(discussion: instantiate_resource, actor: current_user)
    respond_with_resource
  end

  def move_comments
    EventService.move_comments(discussion: load_resource, params: params, actor: current_user)
    respond_with_resource
  end

  def history
    load_and_authorize(:discussion)
    res = DiscussionReader.joins(:user).where(discussion: @discussion).where.not(last_read_at: nil).map do |reader|
      {reader_id: reader.id,
       last_read_at: reader.last_read_at,
       user_name: reader.user.name }
    end
    render root: false, json: res
  end

  def pin
    service.pin discussion: load_resource, actor: current_user
    respond_with_resource
  end

  def set_volume
    update_reader volume: params[:volume]
  end

  private
  def group_ids
    if params.has_key?(:include_subgroups) && params[:include_subgroups] == 'false'
      [@group&.id]
    else
      @group&.id_and_subgroup_ids
    end
  end

  def split_tags
    params[:tags].to_s.split('|')
  end

  def default_scope
    super.merge(tag_cache: DiscussionTagCache.new(Array(resource || collection)).data)
  end

  def accessible_records
    Queries::VisibleDiscussions.new(user: current_user, group_ids: group_ids, tags: split_tags)
  end

  def update_reader(params = {})
    service.update_reader discussion: load_resource, params: params, actor: current_user
    respond_with_resource
  end

  def collection_for_index(collection, filter: params[:filter])
    collection = Queries::VisibleDiscussions.new(user: current_user, group_ids: group_ids, tags: split_tags, show_public: true)
    case filter
    when 'show_closed' then collection.is_closed
    when 'all' then collection
    else collection.is_open
    end.sorted_by_importance
  end

  def collection_for_dashboard(collection, filter: params[:filter])
    collection = Queries::VisibleDiscussions.new(user: current_user)
    case filter
    when 'show_muted'  then collection.is_open.muted.sorted_by_latest_activity
    else                    collection.is_open.not_muted.sorted_by_importance
    end
  end

  def collection_for_inbox(collection)
    collection.recent.not_muted.unread.sorted_by_latest_activity.includes(:group, :author)
  end
end
