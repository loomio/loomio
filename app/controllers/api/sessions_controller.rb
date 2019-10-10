class API::SessionsController < Devise::SessionsController
  include PrettyUrlHelper
  before_action :configure_permitted_parameters

  def create
    if user = attempt_login
      user.reactivate! if pending_login_token&.is_reactivation
      sign_in(user)
      flash[:notice] = t(:'devise.sessions.signed_in')
      user.update(name: resource_params[:name]) if resource_params[:name]
      render json: Boot::User.new(user).payload
    else
      render json: { errors: failure_message }, status: 401
    end
    session.delete(:pending_login_token)
  end

  def destroy
    ActionCable.server.broadcast current_user.message_channel, action: :logged_out
    sign_out resource_name
    flash[:notice] = t(:'devise.sessions.signed_out')
    render json: { success: :ok }
  end

  private

  def failure_message
    if resource_params[:password] && User.where(email: resource_params[:email]).where.not(locked_at: nil).exists?
      { password: [:'auth_form.account_locked'] }
    else
      { password: [:'auth_form.invalid_password'] }
    end
  end

  def attempt_login
    if pending_login_token&.useable?
      pending_login_token.user
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
