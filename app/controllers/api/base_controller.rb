class Api::BaseController < BaseController
  respond_to :json

  protected
  def render_event_or_invalid_model(event, model)
    if event
      render json: event
    else
      render json: model, serializer: InvalidModelSerializer, status: 400
    end
  end
end
