class Api::V1::DiscussionsController < Api::V1::RestfulController
  def create
    instantiate_resource
    if resource_params[:forked_event_ids] && resource_params[:forked_event_ids].any?
      EventService.move_comments(discussion: create_action.discussion, params: resource_params, actor: current_user)
    else
      create_action
    end
    respond_with_resource
  end

  def create_action
    @event = service.create(**{resource_symbol => resource, actor: current_user, params: resource_params})
  end

  def show
    load_and_authorize(:discussion)

    if resource.closed_at && resource.closer_id.nil?
      if closed_event = Event.where(discussion_id: resource.id, kind: 'discussion_closed').order(:id).last
        resource.update_attribute(:closer_id, closed_event.user_id)
      else
        resource.update_attribute(:closer_id, resource.author_id)
      end
    end

    # this is desperation in code, but better than auto create when nil on method call
    if resource.created_event.nil?
      EventService.repair_thread(resource.id)
      resource.reload
    end

    accept_pending_membership
    respond_with_resource
  end

  def index
    load_and_authorize(:group, optional: true)
    instantiate_collection do |collection|
      DiscussionQuery.filter(chain: collection, filter: params[:filter])
    end
    respond_with_collection
  end

  def dashboard
    raise CanCan::AccessDenied.new unless current_user.is_logged_in?
    @accessible_records = DiscussionQuery.dashboard(user: current_user)
    instantiate_collection { |collection| collection.is_open.order_by_latest_activity }
    respond_with_collection
  end

  def direct
    @accessible_records = DiscussionQuery.visible_to(
                          user: current_user,
                          or_public: false,
                          or_subgroups: false,
                          group_ids: nil,
                          only_direct: true)
    instantiate_collection { |collection| collection.order_by_latest_activity }
    respond_with_collection
  end

  def inbox
    raise CanCan::AccessDenied.new unless current_user.is_logged_in?
    @accessible_records = DiscussionQuery.inbox(user: current_user)
    instantiate_collection { |collection| collection.recent.order_by_latest_activity }
    respond_with_collection
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

  def history
    load_and_authorize(:discussion)

    if @discussion.polls.kept.where(anonymous:true).any?
      render root: false, json: {message: I18n.t("discussion_last_seen_by.disabled_anonymous_polls")}, status: 403
    else
      res = DiscussionReader.joins(:user).where(discussion: @discussion).where.not(last_read_at: nil).map do |reader|
        {reader_id: reader.id,
         last_read_at: reader.last_read_at,
         user_name: reader.user.name_or_username }
      end
      render root: false, json: res
    end
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

  def move_comments
    EventService.move_comments(discussion: load_resource, params: params, actor: current_user)
    respond_with_resource
  end

  def pin
    service.pin discussion: load_resource, actor: current_user
    respond_with_resource
  end

  def unpin
    service.unpin discussion: load_resource, actor: current_user
    respond_with_resource
  end

  def set_volume
    update_reader volume: params[:volume]
  end

  def discard
    @discussion = load_resource
    service.discard discussion: @discussion, actor: current_user
    respond_with_resource
  end

  private
  def group_ids
    case params[:subgroups]
    when 'all'
      Array(@group&.id_and_subgroup_ids)
    when 'mine'
      if current_user.is_logged_in?
        [@group&.id].concat(current_user.group_ids & @group&.id_and_subgroup_ids)
      else
        [@group&.id]
      end
    else
      [@group&.id]
    end.compact
  end

  def discussion_ids
    params.fetch(:xids, '').split('x').map(&:to_i).uniq
  end

  def split_tags
    Array(params[:tags].to_s).reject(&:blank?)
  end

  def accessible_records
    @accessible_records ||= DiscussionQuery.visible_to(
      user: current_user,
      group_ids: group_ids,
      tags: split_tags,
      discussion_ids: discussion_ids)
  end

  def update_reader(params = {})
    service.update_reader discussion: load_resource, params: params, actor: current_user
    respond_with_resource
  end
end
