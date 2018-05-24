class API::SessionsController < Devise::SessionsController
  include PrettyUrlHelper
  before_action :configure_permitted_parameters

  def create
    if user = attempt_login
      user.reactivate! if pending_token&.is_reactivation
      sign_in(user)
      flash[:notice] = t(:'devise.sessions.signed_in')
      render json: BootData.new(user).data
    else
      render json: { errors: { password: [t(:"user.error.bad_login")] } }, status: 401
    end
    session.delete(:pending_token)
  end

  def destroy
    ActionCable.server.broadcast current_user.message_channel, action: :logged_out
    sign_out resource_name
    flash[:notice] = t(:'devise.sessions.signed_out')
    render json: { success: :ok }
  end

  private

  def attempt_login
    if pending_token&.useable?
      pending_token.user
    elsif pending_membership
      pending_membership.user.verified_or_self
    elsif resource_params[:code]
      login_token_user
    else
      warden.authenticate(scope: resource_name)
    end
  end

  def login_token_user
    token = LoginToken.unused.find_by(code: resource_params.require(:code))
    token.user if token&.user&.email == resource_params.require(:email)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in) do |u|
      u.permit(:code, :email, :password, :remember_me)
    end
  end
end
