class Api::V1::SessionsController < Devise::SessionsController
  include PrettyUrlHelper
  before_action :configure_permitted_parameters

  def create
    unless turnstile_ok?
      render json: { errors: { turnstile: [I18n.t('auth_form.turnstile_required')] } }, status: 403
      return
    end
    if user = attempt_login
      sign_in(user)
      flash[:notice] = t(:'devise.sessions.signed_in')
      user.update(name: resource_params[:name]) if resource_params[:name]
      user.update_columns(bounces_count: 0, complaints_count: 0) if user.bounces_count > 0 || user.complaints_count > 0
      render json: Boot::User.new(user, root_url: URI(root_url).origin).payload
      EventBus.broadcast('session_create', user)
      handle_pending_actions(user)
      # if pending_login_token
      #   LoginToken.where(user_id: user.id, code: pending_login_token.code).update_all(used: true)
      # end
    else
      render json: { errors: failure_message }, status: 401
    end
    session.delete(:pending_login_token)
  end

  def destroy
    current_user.update_columns(secret_token: UUIDTools::UUID.random_create.to_s)
    sign_out resource_name

    flash[:notice] = t(:'devise.sessions.signed_out')
    render json: { success: :ok }
  end

  private

  def failure_message
    if resource_params[:password] && User.where(email: resource_params[:email]).where.not(locked_at: nil).exists?
      { password: [I18n.t('auth_form.account_locked')] }
    elsif pending_login_token
      { token: [I18n.t('auth_form.invalid_token')] }
    else
      { password: [I18n.t('auth_form.invalid_password')] }
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
      u.permit(:code, :email, :password, :remember_me, :turnstile_token)
    end
  end

  # Users who request a login-token have already solved a CAPTCHA to get the
  # email — don't ask them to solve a second one (their previous token is now
  # burnt at Cloudflare). The per-email sessions throttle + 6-digit code
  # entropy make code-flow safe without a fresh CAPTCHA.
  def turnstile_ok?
    return true if pending_login_token&.useable?
    return true if resource_params[:code].present?
    TurnstileService.verify(params.dig(:user, :turnstile_token) || params[:turnstile_token],
                            remote_ip: request.remote_ip)
  end
end
