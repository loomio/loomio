class API::EventsController < API::RestfulController
  include UsesDiscussionReaders

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

  # we always want to serialize out events in the events controller
  alias :events_to_serialize :resources_to_serialize

  # events will define their own serializer through the `active_model_serializer` method
  def resource_serializer
    nil
  end
end
