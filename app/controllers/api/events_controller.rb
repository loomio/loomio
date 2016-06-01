class API::EventsController < API::RestfulController
  include UsesDiscussionReaders
  EventCollection = Struct.new(:events)

  private

  def accessible_records
    load_and_authorize(:discussion).items.sequenced
  end

  def page_collection(collection)
    collection.where('sequence_id >= ?', sequence_id_for(collection))
              .includes(:eventable)
              .limit(params[:per] || default_page_size)
  end

  def default_page_size
    30
  end

  def sequence_id_for(collection)
    sequence_id_for_comment(collection) || params[:from] || 0
  end

  def sequence_id_for_comment(collection)
    collection.find_by(eventable_type: "Comment", eventable_id: params[:comment_id]).try(:sequence_id)
  end

  def respond_with_collection(resources: collection, scope: default_scope, serializer: resource_serializer)
    render json: EventCollection.new(resources), scope: scope, serializer: resource_serializer
  end

  def resource_serializer
    Events::ArraySerializer
  end
end
