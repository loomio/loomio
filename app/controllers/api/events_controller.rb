class API::EventsController < API::RestfulController
  include UsesDiscussionReaders

  private

  def visible_records
    load_and_authorize :discussion
    resource_class.
      includes(:user).
      where(discussion: @discussion).sequenced
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
    (sequence_id_for_comment(collection) if params[:comment_id].present?) || params[:from] || 0
  end

  def sequence_id_for_comment(collection)
    collection.where(eventable_type: "Comment", eventable_id: params[:comment_id]).pluck(:sequence_id).first
  end
end
