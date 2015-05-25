class API::EventsController < API::RestfulController

  private

  def visible_records
    load_and_authorize :discussion
    resource_class.where(discussion: @discussion).order(sequence_id: :asc)
  end

  def page_collection(collection)
    collection.where('sequence_id >= ?', params[:from] || 0)
              .limit(params[:per] || default_page_size)
  end

  def default_page_size
    30
  end

end
