class API::EventsController < API::RestfulController
  include UsesDiscussionReaders
  
  private

  def accessible_records
    records = load_and_authorize(:discussion).items.sequenced
    records = records.includes(:user, :discussion, :eventable, parent: [:user, :eventable])
    records = records.where(parent_id: params[:parent_id]) if params[:parent_id]
    records
  end

  def page_collection(collection)
    if params[:parent_id]
      collection.where('position >= ?', params[:from].to_i)
    else
      collection.where('sequence_id >= ?', sequence_id_for(collection))
    end.limit(params[:per] || default_page_size)
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

  # events will define their own serializer through the `active_model_serializer` method
  def resource_serializer
    nil
  end
end
