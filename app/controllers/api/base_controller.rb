class API::BaseController < ActionController::Base
  #class Api::BaseController < BaseController
  after_filter :increment_measurement
  respond_to :json

  protected
  def render_event_or_model_error(event, model)
    if event
      render json: event, serializer: EventSerializer
    else
      render json: model, serializer: ModelErrorSerializer, status: 400, root: :error
    end
  end

  def increment_measurement
    Measurement.increment(measurement_name)
  end

  def measurement_name
    "#{controller_name}.#{action_name}"
  end

  def permitted_params
    @permitted_params ||= PermittedParams.new(params, current_user)
  end

  def require_authenticated_user
    head 401 unless current_user
  end

  def authenticate_user_by_email_api_key
    user_id = request.headers['Loomio-User-Id']
    key = request.headers['Loomio-Email-API-Key']
    @current_user = User.where(id: user_id, email_api_key: key).first
  end

  def current_user
    @current_user
  end

  def current_ability
    @current_ability ||= AccountAbility.new(current_user)
  end
end
