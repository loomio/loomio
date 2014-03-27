class Api::BaseController < BaseController
  respond_to :json

  protected
  def render_event_or_model_error(event, model)
    if event
      render json: event, serializer: EventSerializer
    else
      render json: model, serializer: ModelErrorSerializer, status: 400, root: :error
    end
  end
end
