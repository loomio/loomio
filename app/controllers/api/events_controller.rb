class API::EventsController < API::RestfulController
  include UsesDiscussionReaders

  def remove_from_thread
    service.remove_from_thread(event: load_resource, actor: current_user)
    respond_with_resource
  end

  def comment
    discussion = load_and_authorize(:discussion)
    self.resource = Event.find_by!(kind: "new_comment", eventable_type: "Comment", eventable_id: params[:comment_id])
    respond_with_resource
  end

  private

  def default_scope
    super.merge(current_user: current_user, my_stances_cache: Caches::Stance.new(user: current_user, parents: resources_to_serialize))
  end

  def order
    %w(sequence_id position).detect {|col| col == params[:order] } || "sequence_id"
  end

  def per
    (params[:per] || default_page_size).to_i
  end

  def from
    if params[:from_unread]
      reader = DiscussionReader.for(user: current_user, discussion: @discussion)
      if reader.unread_items_count == 0
        id = @discussion.last_sequence_id - per + 2
        if id > 0
          id
        else
          @discussion.first_sequence_id
        end
      else
        reader.first_unread_sequence_id
      end
    elsif params[:from_sequence_id_of_position]
      Event.find_by!(discussion: @discussion, depth: 1, position: params[:from_sequence_id_of_position])&.sequence_id
    elsif params[:comment_id]
      Event.find_by!(kind: "new_comment", eventable_type: "Comment", eventable_id: params[:comment_id])&.sequence_id
    else
      params[:from] || 0
    end
  end

  def accessible_records
    load_and_authorize(:discussion)
    records = @discussion.items.distinct.
                includes(:user, :discussion, :eventable, parent: [:user, :eventable])

    records = records.where("#{order} >= ?", from)

    if params[:kind]
      records = records.where("kind in (?)", params[:kind].split(','))
    end

    %w(parent_id depth sequence_id position).each do |name|
      records = records.where(name => params[name]) if params[name]
      records = records.where("#{name} >= ?", params["min_#{name}"]) if params["min_#{name}"]
      records = records.where("#{name} <= ?", params["max_#{name}"]) if params["max_#{name}"]
    end
    records
  end

  def page_collection(collection)
    collection.order(order).limit(per)
  end

  def default_page_size
    30
  end

  # def associations_for_serializion(collection)
  #   collection.map(&:discussion).map(:author_id)
  #   discussion_readers = ...
  #   eventables = collection.map(&:eventable)
  #   # then manually invoke serializers
  #   {
  #     users: UserSerializer.serialize User.where(id: collection.pluck(:author_id), asdkjaldsjasdlkj)
  #     events: EventSerializer collection,
  #     reactions: RectionSerializer Reaction.where(reactable: collection.map(:eventable))
  #     discussions:
  #     documents: DocumentSerializer
  #     tags:
  #     comments:
  #     polls:
  #     stances
  #     memberships:
  #     groups:
  #   }
  # end

  # we always want to serialize out events in the events controller
  alias :events_to_serialize :resources_to_serialize

  # events will define their own serializer through the `active_model_serializer` method
  def resource_serializer
    nil
  end
end
