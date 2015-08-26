class API::BaseController < ActionController::Base
  include CurrentUserHelper
  include ::ProtectedFromForgery

  before_filter :require_authenticated_user, except: :index

  skip_after_filter :intercom_rails_auto_include

  protected

  def permitted_params
    @permitted_params ||= PermittedParams.new(params)
  end

  def require_authenticated_user
    head 401 unless current_user
  end

  def authenticate_user_by_email_api_key
    user_id = request.headers['Loomio-User-Id']
    key = request.headers['Loomio-Email-API-Key']
    @current_user = User.where(id: user_id, email_api_key: key).first
  end
end
