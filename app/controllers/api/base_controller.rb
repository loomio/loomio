class API::BaseController < ActionController::Base

  protected
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

