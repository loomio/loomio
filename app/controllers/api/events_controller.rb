class API::EventsController < API::BaseController
  def index
    events = Event.where(discussion_id: params[:discussion_id]).page(params[:page]).to_a
    #raise events.inspect
    render json: events
  end
end
