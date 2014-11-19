class API::EventsController < API::RestfulController
  def index
    load_and_authorize_discussion
    @events = Event.where(discussion: @discussion).order(:created_at).page(params[:page]).per(10).to_a
    respond_with_collection
  end
end
