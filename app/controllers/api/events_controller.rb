class API::EventsController < API::RestfulController

  def dashboard_events
    @events = DashboardEventsQuery.latest_events_for(user: current_user)
    respond_with_collection
  end

  private

  def visible_records
    load_and_authorize_discussion
    Event.where(discussion: @discussion).order(sequence_id: params_reverse? ? :desc : :asc)
  end

  def page_collection(collection)
    if params_reverse?
      collection.where('sequence_id < ?', params[:from] || 0)
    else
      collection.where('sequence_id > ?', params[:from] || 0)
    end.limit(params[:per] || default_page_size)
  end

  def default_page_size
    50
  end

  def params_reverse?
    params[:reverse] == 'true'
  end

end
