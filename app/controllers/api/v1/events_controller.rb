class Api::V1::EventsController < Api::V1::RestfulController
  def position_keys
    load_and_authorize_topic
    keys = Event.where(topic_id: @topic.id).pluck(:position_key).sort
    render json: keys, root: 'position_keys'
  end

  def timeline
    load_and_authorize_topic
    events = Event.where(topic_id: @topic.id)
    anonymous_stance_event_ids = events
      .where(eventable_type: 'Stance')
      .joins('INNER JOIN stances ON stances.id = events.eventable_id')
      .joins('INNER JOIN polls ON polls.id = stances.poll_id')
      .where(polls: { anonymous: true })
      .pluck(:id)
      .index_with(true)

    data = events.order(:position_key)
                 .pluck(:id, :position_key, :sequence_id, :created_at, :user_id, :depth)
                 .map do |id, position_key, sequence_id, created_at, user_id, depth|
      anonymous_stance_event = anonymous_stance_event_ids[id]
      [position_key, sequence_id, anonymous_stance_event ? nil : created_at, anonymous_stance_event ? nil : user_id, depth]
    end
    render json: data.to_json, root: 'timeline'
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

  def descendant_authors
    event = Event.find(params[:id])
    current_user.ability.authorize!(:show, event.topic)

    # Up to 16 distinct authors, ordered by the sequence_id of their last
    # event under this one.
    user_ids = Event.where(topic_id: event.topic_id)
                    .where("position_key LIKE ?", "#{event.position_key}-%")
                    .where.not(user_id: nil)
                    .group(:user_id)
                    .order(Arel.sql('MAX(events.sequence_id) DESC'))
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

    if params[:unread_or_newest].present?
      if params[:poll_id] || params[:poll_key]
        poll = ModelLocator.new(:poll, params).locate!

        # A poll key can identify a poll embedded inside another topic. In that
        # case the page should open the parent thread at the poll_created event,
        # then include following activity so the surrounding conversation renders.
        if @topic.topicable != poll
          poll_created = records.find_by!(kind: 'poll_created', eventable: poll)
          return records.where("sequence_id >= ?", poll_created.sequence_id).order(:sequence_id)
        end
      end

      reader = TopicReader.for(user: current_user, topic: @topic)
      topic_ranges = @topic.ranges
      unread_ranges = RangeSet.intersect_ranges(reader.unread_ranges, topic_ranges)
      read_ranges = RangeSet.intersect_ranges(reader.read_ranges, topic_ranges)

      if unread_ranges.any?
        if RangeSet.length(unread_ranges) > RangeSet.length(read_ranges)
          records = records.where.not(sequence_id: ranges_for_query(read_ranges)) if read_ranges.any?
          return records.order(:sequence_id)
        else
          return records.where(sequence_id: ranges_for_query(unread_ranges)).order(:sequence_id)
        end
      else
        return records.order(sequence_id: :desc)
      end
    end

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

  def ranges_for_query(ranges)
    ranges.map { |range| range.first..range.last }
  end

  def default_page_size
    30
  end

  def count_collection
    false
  end
end
