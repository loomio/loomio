class API::B3::UsersController < API::V1::SnorlaxBase
  skip_before_action :verify_authenticity_token
  before_action :authenticate_api_key!
  include ::LoadAndAuthorize

  def authenticate_api_key!
    raise CanCan::AccessDenied unless ENV.fetch('B3_API_KEY', '').length > 16
    raise CanCan::AccessDenied unless params[:b3_api_key] == ENV['B3_API_KEY']
  end

  def deactivate
    user = User.active.find(params[:id]) # throws 404 if not present
    DeactivateUserWorker.perform_async(user.id, user.id)
    render json: {success: :ok}
  end

  def reactivate
    User.deactivated.find(params[:id]) # throws 404 if not present
    UserService.reactivate(params[:id])
    render json: {success: :ok}
  end
end
