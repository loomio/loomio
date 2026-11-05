class Api::V1::TopicItemsController < Api::V1::RestfulController
  def tags
    item = TopicItem.find(params[:id])
    TopicItemService.update_tags(topic_item: item, tags: params[:tags], actor: current_user)
    self.resource = item
    respond_with_resource
  end

  # Page matches, then let RecordCache include their bounded display ancestry.
  # Context rows do not count towards the match page or change its ordering.
  def tagged
    load_and_authorize_topic
    matches = TopicItem.tags_visible.where(topic_id: @topic.id)
      .where('topic_items.tags @> ARRAY[?]::varchar[]', [params.require(:tag)])
      .order(:position_key, :id)
    self.collection = page_collection_bounded(matches)
    respond_with_collection
  end

  def index
    self.collection = topic_items_query.collection
    respond_with_collection
  end

  def position_keys
    load_and_authorize_topic
    keys = TopicItem.where(topic_id: @topic.id).pluck(:position_key).sort
    render json: keys, root: 'position_keys'
  end

  def timeline
    load_and_authorize_topic
    topic_items = TopicItem.where(topic_id: @topic.id)
    data = topic_items.order(:position_key)
                 .pluck(:id, :position_key, :sequence_id, :created_at, :user_id, :depth)
                 .map do |_id, position_key, sequence_id, created_at, user_id, depth|
      [position_key, sequence_id, created_at, user_id, depth]
    end
    render json: data.to_json, root: 'timeline'
  end

  def comment
    load_and_authorize_topic
    self.resource = TopicItem.where(topic_id: @topic.id).find_by!(kind: "new_comment", itemable_type: "Comment", itemable_id: params[:comment_id])
    respond_with_resource
  end

  def pin
    @topic_item = TopicItem.find(params[:id])
    current_user.ability.authorize!(:pin, @topic_item)
    @topic_item.update(pinned: true, pinned_title: params[:pinned_title])
    render json: MessageChannelService.serialize_models(@topic_item, scope: default_scope)
  end

  def unpin
    @topic_item = TopicItem.find(params[:id])
    current_user.ability.authorize!(:unpin, @topic_item)
    @topic_item.update(pinned: false)
    render json: MessageChannelService.serialize_models(@topic_item, scope: default_scope)
  end

  def descendant_authors
    topic_item = TopicItem.find(params[:id])
    current_user.ability.authorize!(:show, topic_item.topic)

    # Up to 16 distinct authors, ordered by the sequence_id of their last
    # topic_item under this one.
    user_ids = TopicItem.where(topic_id: topic_item.topic_id)
                    .where("position_key LIKE ?", "#{topic_item.position_key}-%")
                    .where.not(user_id: nil)
                    .group(:user_id)
                    .order(Arel.sql('MAX(topic_items.sequence_id) DESC'))
                    .limit(16)
                    .pluck(:user_id)

    users = User.active.where(id: user_ids).index_by(&:id).values_at(*user_ids).compact
    render json: {
      users: ActiveModel::ArraySerializer.new(users, each_serializer: AuthorSerializer).as_json
    }
  end

  def count
    render json: accessible_records.count
  end

  private

  def load_and_authorize_topic
    if params[:topic_id]
      @topic = Topic.find(params[:topic_id])
    elsif params[:discussion_id] || params[:discussion_key]
      @topic = ModelLocator.new(:discussion, params).locate!.topic
    elsif params[:poll_id] || params[:poll_key]
      @topic = ModelLocator.new(:poll, params).locate!.topic
    end
    current_user.ability.authorize!(:show, @topic)
  end

  def accessible_records
    topic_items_query.accessible_records
  end

  def topic_items_query
    load_and_authorize_topic
    TopicItemsQuery.new(topic: @topic, user: current_user, params: params.to_unsafe_h)
  end

  def count_collection
    false
  end
end
