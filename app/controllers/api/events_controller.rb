class API::EventsController < API::RestfulController
  include UsesDiscussionReaders

  def mark_as_read
    service.mark_as_read(event: load_resource, actor: current_user)
    respond_with_reader
  end

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
    sequence_id_for_comment(collection) || params[:from].to_i
  end

  def sequence_id_for_comment(collection)
    collection.find_by(eventable_type: "Comment", eventable_id: params[:comment_id]).try(:sequence_id)
  end

  # we always want to serialize out events in the events controller
  alias :events_to_serialize :resources_to_serialize

  def respond_with_reader(scope: default_scope, serializer: DiscussionReaderSerializer, root: :discussions)
    render json: Array(DiscussionReader.for_model(resource.discussion, current_user)),
           each_serializer: serializer,
           scope: scope,
           root: root
  end

  # events will define their own serializer through the `active_model_serializer` method
  def resource_serializer
    nil
  end
end
