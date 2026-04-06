class Api::V1::TopicsController < Api::V1::RestfulController
  def index
    instantiate_collection
    respond_with_collection
  end

  def dashboard
    raise CanCan::AccessDenied.new unless current_user.is_logged_in?
    instantiate_collection
    respond_with_collection
  end

  def update
    load_resource
    TopicService.update(topic: resource, params: permitted_params.topic, actor: current_user)
    respond_with_resource
  end

  def mark_as_read
    load_resource
    TopicService.mark_as_read(topic: resource, params: params, actor: current_user)
    respond_with_resource
  end

  def mark_as_seen
    load_resource
    TopicService.mark_as_seen(topic: resource, actor: current_user)
    respond_with_resource
  end

  def dismiss
    load_resource
    TopicService.dismiss(topic: resource, actor: current_user)
    respond_with_resource
  end

  def recall
    load_resource
    TopicService.recall(topic: resource, actor: current_user)
    respond_with_resource
  end

  def set_volume
    load_resource
    TopicService.update_reader(topic: resource, params: {volume: params[:volume]}, actor: current_user)
    respond_with_resource
  end

  def pin
    load_resource
    TopicService.pin(topic: resource, actor: current_user)
    respond_with_resource
  end

  def unpin
    load_resource
    TopicService.unpin(topic: resource, actor: current_user)
    respond_with_resource
  end

  def close
    load_resource
    TopicService.close(topic: resource, actor: current_user)
    respond_with_resource
  end

  def reopen
    load_resource
    TopicService.reopen(topic: resource, actor: current_user)
    respond_with_resource
  end

  def move
    load_resource
    TopicService.move(topic: resource, params: params, actor: current_user)
    respond_with_resource
  end

  def move_comments
    load_resource
    EventService.move_comments(topic: resource, params: params, actor: current_user)
    respond_with_resource
  end

  def discard
    load_resource
    TopicService.discard(topic: resource, actor: current_user)
    respond_with_resource
  end

  private

  def accessible_records
    scope = Topic.visible_to(current_user)

    if params[:topicable_type].present?
      scope = scope.where(topicable_type: params[:topicable_type])
    end

    if params[:group_id].present?
      group = Group.find(params[:group_id])
      scope = scope.where(group_id: [group.id] + group.subgroup_ids)
    end

    case params[:filter]
    when 'closed'
      scope = scope.closed
    when 'all'
      # no filter
    else
      scope = scope.not_closed
    end

    tags = Array(params[:tags]).reject(&:blank?)
    scope = scope.tagged(tags) if tags.any?

    scope.recent_activity_first
  end

  def default_page_size
    25
  end
end
