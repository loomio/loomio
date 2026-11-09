class Api::V1::TopicsController < Api::V1::RestfulController
  before_action :require_current_user, except: :index

  def index
    @topics = TopicListQuery.new(user: current_user, params: params.to_unsafe_h).records

    self.collection_count = @topics.count
    @topics = page_collection(@topics)

    respond_with_collection
  end

  def update
    load_resource
    TopicService.update(topic: resource, params: permitted_params.topic, actor: current_user)
    respond_with_resource
  end

  def markdown
    self.resource = load_and_authorize(:topic, :export)
    render json: {markdown: ThreadMarkdownService.render(topic: resource, user: current_user)}
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
    respond_ok
  end

  def recall
    load_resource
    TopicService.recall(topic: resource, actor: current_user)
    respond_with_resource
  end

  def set_volume
    load_resource
    TopicService.update_reader(
      topic: resource,
      params: params.slice(:volume_email, :volume_push),
      actor: current_user
    )
    respond_with_resource
  end

  def tags
    load_resource
    TopicService.update_tags(topic: resource, tags: params[:tags], actor: current_user)
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
    TopicItemService.move_comments(topic: resource, params: params, actor: current_user)
    respond_with_resource
  end

  def discard
    load_resource
    TopicService.discard(topic: resource, actor: current_user)
    respond_with_resource
  end

  def history
    topic = load_and_authorize(:topic)

    if topic.has_anonymous_polls?
      render root: false, json: {message: I18n.t("discussion_last_seen_by.disabled_anonymous_polls")}, status: 403
    else
      readers = TopicReader.joins(:user)
                           .preload(user: { uploaded_avatar_attachment: :blob })
                           .where(topic_id: topic.id)
                           .where.not(last_read_at: nil)
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
