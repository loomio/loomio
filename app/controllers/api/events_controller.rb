class API::EventsController < API::RestfulController
  include UsesDiscussionReaders

  private

  def accessible_records
    load_and_authorize :discussion
    @discussion.items.sequenced
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
end
