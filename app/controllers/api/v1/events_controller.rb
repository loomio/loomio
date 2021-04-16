class API::V1::EventsController < API::V1::RestfulController
  def position_keys
    load_and_authorize(:discussion)
    keys = Event.where(discussion_id: params[:discussion_id]).pluck(:position_key).sort
    render json: keys, root: 'position_keys'
  end

  def remove_from_thread
    service.remove_from_thread(event: load_resource, actor: current_user)
    respond_with_resource
  end

  def comment
    load_and_authorize(:discussion)
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

  private

  def order
    %w(sequence_id position position_key).detect {|col| col == params[:order] } || "sequence_id"
  end

  def per
    (params[:per] || default_page_size).to_i
  end

  def from
    # if params[:from_unread]
    #   reader = DiscussionReader.for(user: current_user, discussion: @discussion)
    #   if reader.unread_items_count == 0
    #     id = @discussion.last_sequence_id - per + 2
    #     if id > 0
    #       id
    #     else
    #       @discussion.first_sequence_id
    #     end
    #   else
    #     reader.first_unread_sequence_id
    #   end
    if params[:from_sequence_id_of_position]
      position = [params[:from_sequence_id_of_position].to_i, 1].max
      Event.find_by!(discussion: @discussion, depth: 1, position: position)&.sequence_id
    elsif params[:comment_id]
      Event.find_by!(kind: "new_comment", eventable_type: "Comment", eventable_id: params[:comment_id])&.sequence_id
    else
      params[:from] || 0
    end
  end

  def accessible_records
    load_and_authorize(:discussion)
    records = Event.where(discussion_id: @discussion.id)

    if %w[position_key sequence_id].include?(params[:order_by])
      records = records.order("#{params[:order_by]}#{params[:order_desc] ? " DESC" : ''}")
    else
      records = records.where("#{order} >= ?", from)
    end

    if params[:unread] == 'true'
      reader = DiscussionReader.for(user: current_user, discussion: @discussion)
      # could also be where in unread_ranges, but there is a bug on http://localhost:8080/s/njwV5RpS
      records = records.where.not(sequence_id: reader.read_ranges.map{ |range| range[0]..range[1] })
    end

    if params[:pinned] == 'true'
      records = records.where(pinned: true)
    end

    if params[:kind]
      records = records.where("kind in (?)", params[:kind].split(','))
    end

    %w(parent_id depth sequence_id position position_key).each do |name|
      records = records.where(name => params[name]) if params[name]
      # records = records.where("#{name} >= ?", params["min_#{name}"]) if params["min_#{name}"]
      # records = records.where("#{name} <= ?", params["max_#{name}"]) if params["max_#{name}"]
      records = records.where("#{name} = ?", params["#{name}"]) if params["#{name}"]
      records = records.where("#{name} < ?", params["#{name}_lt"]) if params["#{name}_lt"]
      records = records.where("#{name} > ?", params["#{name}_gt"]) if params["#{name}_gt"]
      records = records.where("#{name} <= ?", params["#{name}_lte"]) if params["#{name}_lte"]
      records = records.where("#{name} >= ?", params["#{name}_gte"]) if params["#{name}_gte"]
      records = records.where("#{name} like ?", params["#{name}_sw"]+"%") if params["#{name}_sw"]
    end
    # records = records.where("position_key like ?", params["position_key_sw"]+"%") if params["position_key_sw"]
    records
  end

  def page_collection(collection)
    if params[:until_sequence_id_of_position]
      position = [params[:until_sequence_id_of_position].to_i, @discussion.created_event.child_count].min
      event = Event.find_by!(discussion: @discussion, depth: 1, position: position)
      max_sequence_id = event.sequence_id + event.child_count
      collection.where("sequence_id <= ?", max_sequence_id).order('depth, position').limit(per)
    else
      collection.order(order).limit(per)
    end
  end

  def default_page_size
    30
  end
end
