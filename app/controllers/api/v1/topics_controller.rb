class Api::V1::TopicsController < Api::V1::RestfulController
  before_action :require_current_user, except: :index

  def index
    @topics = TopicQuery.visible_to(
                          user: current_user,
                          or_subgroups: false,
                          or_public: false,
                          only_unread: params.has_key?(:unread)
                        ).recent_activity_first

    if params[:topicable_type].present?
      @topics = @topics.where(topicable_type: params[:topicable_type])
    end

    if params[:group_id].present?
      group = Group.find(params[:group_id])
      @topics = @topics.where(group_id: [group.id] + group.subgroup_ids)
    end

    case params[:filter]
    when 'closed'
      @topics = @topics.closed
    when 'all'
      # no filter
    else
      @topics = @topics.not_closed
    end

    tags = Array(params[:tags]).reject(&:blank?)
    @topics = @topics.tagged(tags) if tags.any?

    @topics = page_collection(@topics)

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

  end

  def default_page_size
    25
  end
end
