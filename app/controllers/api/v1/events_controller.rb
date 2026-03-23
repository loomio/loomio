class Api::V1::EventsController < Api::V1::RestfulController
  def position_keys
    load_and_authorize_topic
    keys = Event.where(topic_id: @topic.id).pluck(:position_key).sort
    render json: keys, root: 'position_keys'
  end

  def timeline
    load_and_authorize_topic
    data = Event.where(topic_id: @topic.id)
                .order(:position_key)
                .pluck(:position_key, :sequence_id, :created_at, :user_id, :depth, :descendant_count)
    render json: data.to_json, root: 'timeline'
  end

  def remove_from_thread
    service.remove_from_thread(event: load_resource, actor: current_user)
    respond_with_resource
  end

  def comment
    load_and_authorize_topic
    self.resource = Event.find_by!(kind: "new_comment", eventable_type: "Comment", eventable_id: params[:comment_id])
    respond_with_resource
  end

  def pin
    @event = Event.find(params[:id])
    current_user.ability.authorize!(:pin, @event)
    @event.update(pinned: true, pinned_title: params[:pinned_title])
    render json: MessageChannelService.serialize_models(@event, scope: default_scope)
  end

  def unpin
    @event = Event.find(params[:id])
    current_user.ability.authorize!(:unpin, @event)
    @event.update(pinned: false)
    render json: MessageChannelService.serialize_models(@event, scope: default_scope)
  end

  def thread
    load_and_authorize_topic
    accept_pending_membership

    padding = per

    # For in-thread polls (not the topic's own topicable), focus on the poll's created event
    if params[:poll_key]
      poll = Poll.find_by!(key: params[:poll_key])
      if poll != @topic.topicable && (poll_event = poll.created_event)
        params[:sequence_id] ||= poll_event.sequence_id.to_s
      end
    end

    # Context event (sequence_id 0) always included
    context_ids = Event.where(topic_id: @topic.id, sequence_id: 0).pluck(:id)

    window_ids = if @topic.items_count <= 1
      # Empty or single-item thread — just context is enough
      []
    elsif params[:sequence_id]
      from_id = [params[:sequence_id].to_i - padding / 2, 0].max
      Event.where(topic_id: @topic.id)
           .where("sequence_id >= ?", from_id)
           .order(:sequence_id)
           .limit(padding)
           .pluck(:id)
    elsif params[:comment_id]
      comment_seq = Event.find_by!(
        kind: "new_comment",
        eventable_type: "Comment",
        eventable_id: params[:comment_id]
      ).sequence_id
      from_id = [comment_seq - padding / 2, 0].max
      comment_ids = Event.where(topic_id: @topic.id)
                         .where("sequence_id >= ?", from_id)
                         .order(:sequence_id)
                         .limit(padding)
                         .pluck(:id)
      newest_ids = Event.where(topic_id: @topic.id)
                        .order(sequence_id: :desc)
                        .limit(padding)
                        .pluck(:id)
      (comment_ids + newest_ids).uniq
    elsif params[:newest]
      Event.where(topic_id: @topic.id)
           .order(sequence_id: :desc)
           .limit(padding)
           .pluck(:id)
    else
      # Default: use reader state to decide
      reader = TopicReader.find_by(topic_id: @topic.id, user_id: current_user.id)
      if reader && reader.last_read_at && reader.first_unread_sequence_id > 0
        # Has unread content — load from first unread + newest
        unread_ids = Event.where(topic_id: @topic.id, sequence_id: reader.unread_ranges.map { |r| r[0]..r[1] })
                          .order(:sequence_id)
                          .limit(padding)
                          .pluck(:id)
        newest_ids = Event.where(topic_id: @topic.id)
                          .order(sequence_id: :desc)
                          .limit(padding)
                          .pluck(:id)
        (unread_ids + newest_ids).uniq
      elsif reader && reader.last_read_at
        # All read — show newest
        Event.where(topic_id: @topic.id)
             .order(sequence_id: :desc)
             .limit(padding)
             .pluck(:id)
      else
        # Never read
        if @topic.newest_first
          Event.where(topic_id: @topic.id)
               .order(sequence_id: :desc)
               .limit(padding)
               .pluck(:id)
        else
          Event.where(topic_id: @topic.id)
               .order(:sequence_id)
               .limit(padding)
               .pluck(:id)
        end
      end
    end

    self.collection = Event.where(id: (context_ids + window_ids).uniq)
    respond_with_collection
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

  def order
    %w(sequence_id position position_key).detect {|col| col == params[:order] } || "sequence_id"
  end

  def per
    (params[:per] || default_page_size).to_i
  end

  def from
    if params[:comment_id]
      Event.find_by!(kind: "new_comment", eventable_type: "Comment", eventable_id: params[:comment_id])&.sequence_id
    else
      params[:from] || 0
    end
  end

  def accessible_records
    load_and_authorize_topic
    records = Event.where(topic_id: @topic.id)

    if %w[position_key sequence_id].include?(params[:order_by])
      records = records.order("#{params[:order_by]}#{params[:order_desc] ? " DESC" : ''}")
    else
      records = records.where("#{order} >= ?", from)
    end

    if params[:sequence_id_in]
      ranges = params[:sequence_id_in].split('_').map { |range| range.split('-').map(&:to_i) }.map { |range| range[0]..range[1] }
      records = records.where(sequence_id: ranges)
    end

    if params[:sequence_id_not_in]
      ranges = params[:sequence_id_not_in].split('_').map { |range| range.split('-').map(&:to_i) }.map { |range| range[0]..range[1] }
      records = records.where.not(sequence_id: ranges)
    end

    if params[:pinned] == 'true'
      records = records.where(pinned: true)
    end

    if params[:kind]
      records = records.where("kind in (?)", params[:kind].split(','))
    end

    %w(parent_id depth sequence_id position position_key).each do |name|
      records = records.where(name => params[name]) if params[name]
      records = records.where("#{name} = ?", params["#{name}"]) if params["#{name}"]
      records = records.where("#{name} < ?", params["#{name}_lt"]) if params["#{name}_lt"]
      records = records.where("#{name} > ?", params["#{name}_gt"]) if params["#{name}_gt"]
      records = records.where("#{name} <= ?", params["#{name}_lte"]) if params["#{name}_lte"]
      records = records.where("#{name} >= ?", params["#{name}_gte"]) if params["#{name}_gte"]
      records = records.where("#{name} like ?", params["#{name}_sw"]+"%") if params["#{name}_sw"]
    end
    records
  end

  def page_collection(collection)
    collection.order(order).limit(per)
  end

  def default_page_size
    30
  end

  def count_collection
    false
  end
end
