class API::EventsController < API::RestfulController

  private

  def visible_records
    load_and_authorize_discussion
    Event.where(discussion: @discussion).order(sequence_id: params[:reverse] ? :desc : :asc)
  end

  def page_collection(collection)
    if params[:reverse]
      collection.where('sequence_id < ?', params[:from] || 0)
    else
      collection.where('sequence_id > ?', params[:from] || 0)
    end.limit(params[:per] || default_page_size)
  end

  def default_page_size
    50
  end

end
