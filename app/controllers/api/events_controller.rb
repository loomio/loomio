class API::EventsController < API::RestfulController
  include DashboardHelper

  def dashboard_by_date
    @events = page_collection dashboard_events
    respond_with_collection
  end

  def dashboard_by_group
    @events = grouped dashboard_events.group_by(&:organization_id)
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
