class Api::V1::TopicsController < Api::V1::RestfulController
  def index
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
    scope = Topic.joins("INNER JOIN pg_search_documents psd ON psd.topic_id = topics.id
                         AND psd.searchable_type = topics.topicable_type
                         AND psd.searchable_id = topics.topicable_id")
                 .joins("LEFT OUTER JOIN groups ON topics.group_id = groups.id")
                 .joins("LEFT OUTER JOIN topic_readers dr ON dr.topic_id = topics.id AND dr.user_id = #{current_user.id}")
                 .where("groups.archived_at IS NULL OR topics.group_id IS NULL")
                 .where("(topics.private = false) OR
                         (topics.group_id IN (:user_group_ids)) OR
                         (dr.id IS NOT NULL AND dr.revoked_at IS NULL AND dr.guest = TRUE) OR
                         (groups.parent_members_can_see_discussions = TRUE AND groups.parent_id IN (:user_group_ids))",
                         user_group_ids: current_user.group_ids)

    scope = scope.where(group_id: params[:group_id].to_i) if params[:group_id].present?

    case params[:filter]
    when 'closed'
      scope = scope.where.not(closed_at: nil)
    when 'all'
      # no filter
    else
      scope = scope.where(closed_at: nil)
    end

    tags = Array(params[:tags]).reject(&:blank?)
    scope = scope.where("psd.tags @> ARRAY[?]::varchar[]", tags) if tags.any?

    scope.order(last_activity_at: :desc)
  end

  def default_page_size
    25
  end
end
