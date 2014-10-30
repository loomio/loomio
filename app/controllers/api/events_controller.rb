class API::EventsController < API::BaseController
  def index
    events = Event.where(discussion_id: params[:discussion_id]).order('id').page(params[:page]).per(10).to_a
    #raise events.inspect
    render json: events
  end
end
