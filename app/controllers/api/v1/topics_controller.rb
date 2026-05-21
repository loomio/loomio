class Api::V1::TopicsController < Api::V1::RestfulController
  before_action :require_current_user, except: :index

  def index
    @topics = TopicQuery.visible_to(
                          user: current_user,
                          or_subgroups: %w[all mine].include?(params[:subgroups]),
                          or_public: params[:group_id].present?,
                          only_direct: params.has_key?(:direct),
                          only_unread: params.has_key?(:unread)
                        ).recent_activity_first

    if params[:topicable_type].present?
      @topics = @topics.where(topicable_type: params[:topicable_type])
    end

    if params[:group_id].present?
      group = Group.find(params[:group_id])
      group_ids = case params[:subgroups]
      when 'all'
        [group.id] + group.subgroup_ids
      when 'mine'
        if current_user.is_logged_in?
          [group.id].concat(current_user.group_ids & group.id_and_subgroup_ids)
        else
          [group.id]
        end
      else
        [group.id]
      end
      @topics = @topics.where(group_id: group_ids.compact.uniq)
    end

    case params[:filter]
    when 'locked'
      @topics = @topics.locked
    when 'unlocked'
      @topics = @topics.not_locked
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

  def lock
    load_resource
    TopicService.lock(topic: resource, actor: current_user)
    respond_with_resource
  end

  def unlock
    load_resource
    TopicService.unlock(topic: resource, actor: current_user)
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

  def history
    topic = load_and_authorize(:topic)

    if Poll.where(topic_id: topic.id).kept.where(anonymous: true).any?
      render root: false, json: {message: I18n.t("discussion_last_seen_by.disabled_anonymous_polls")}, status: 403
    else
      readers = TopicReader.joins(:user).where(topic_id: topic.id).where.not(last_read_at: nil)
      data = readers.map do |reader|
        {last_read_at: reader.last_read_at,
         user_id: reader.user_id }
      end
      users = readers.map { |r| AuthorSerializer.new(r.user).as_json(root: false) }
      render root: false, json: {data: data, users: users}
    end
  end

  private

  def accessible_records

  end

  def default_page_size
    25
  end
end
