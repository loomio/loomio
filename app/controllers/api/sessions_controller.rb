class API::SessionsController < Devise::SessionsController
  before_action :configure_permitted_parameters

  def create
    if user = attempt_login
      sign_in(user)
      render json: BootData.new(user, flash: { notice: t(:"devise.sessions.signed_in") }).payload
    else
      render json: { errors: { password: [t(:"devise.failure.invalid")] } }, status: 401
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
    elsif pending_invitation
      User.verified.find_by(email: pending_invitation.email)
    else
      warden.authenticate(scope: resource_name)
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in) do |u|
      u.permit(:email, :password, :remember_me)
    end
  end

end
