class Api::V1::SessionsController < ActionController::Base
  include Authentication
  include CurrentUserHelper
  include PrettyUrlHelper

  def create
    unless turnstile_ok?
      render json: { errors: { turnstile: [I18n.t('auth_form.turnstile_required')] } }, status: 403
      return
    end
    if user = attempt_login
      start_new_session_for(user)
      handle_pending_actions(user)
      flash[:notice] = t(:'auth_form.signed_in')
      user.update(name: sign_in_params[:name]) if sign_in_params[:name]
      user.update_columns(bounces_count: 0, complaints_count: 0) if user.bounces_count > 0 || user.complaints_count > 0
      render json: Boot::User.new(user, root_url: URI(root_url).origin).payload
      EventBus.broadcast('session_create', user)
    else
      render json: { errors: failure_message }, status: 401
    end
    session.delete(:pending_login_token)
  end

  def destroy
    current_user&.update_columns(secret_token: UUIDTools::UUID.random_create.to_s)
    terminate_session

    flash[:notice] = t(:'auth_form.signed_out')
    render json: { success: :ok }
  end

  private

  def failure_message
    if sign_in_params[:password] && login_user&.access_locked?
      { password: [I18n.t('auth_form.account_locked')] }
    elsif session[:pending_login_token].present?
      { token: [I18n.t('auth_form.invalid_token')] }
    elsif sign_in_params[:password] && login_user.nil?
      { email: [I18n.t('auth_form.email_not_found')] }
    else
      { password: [I18n.t('auth_form.invalid_password')] }
    end
  end

  def login_user
    @login_user ||= User.find_for_authentication(email: sign_in_params[:email])
  end

  def attempt_login
    if pending_login_token&.useable?
      pending_login_token.user
    elsif sign_in_params[:code]
      login_token_user
    else
      attempt_password_login
    end
  end

  def attempt_password_login
    return unless login_user && sign_in_params[:password]
    if login_user.authenticate(sign_in_params[:password])
      login_user
    else
      login_user.increment_failed_attempts!
      nil
    end
  end

  def login_token_user
    LoginToken.transaction do
      token = LoginToken.unused.lock.find_by(code: sign_in_params.require(:code))
      next unless login_token_matches?(token)

      token.update!(used: true)
      token.user
    end
  end

  def login_token_matches?(token)
    sign_in_params[:email].present? && token&.useable? && token.user.email == sign_in_params[:email]
  end

  def usable_login_token_for_code
    return unless sign_in_params[:code].present?

    token = LoginToken.unused.find_by(code: sign_in_params[:code])
    if login_token_matches?(token)
      token
    else
      record_failed_login_code_attempt
      nil
    end
  end

  def record_failed_login_code_attempt
    return if sign_in_params[:email].blank?

    LoginToken.transaction do
      user = User.find_by(email: sign_in_params[:email])
      token = user&.login_tokens&.unused&.lock&.order(created_at: :desc)&.find(&:useable?)
      token&.record_failed_code_attempt!
    end
  end

  def sign_in_params
    @sign_in_params ||= params[:user].present? ? params.require(:user).permit(:code, :email, :password, :remember_me, :turnstile_token, :name) : {}
  end

  # Users who request a login-token have already solved a CAPTCHA to get the
  # email — don't ask them to solve a second one (their previous token is now
  # burnt at Cloudflare). The per-email sessions throttle + 6-digit code
  # entropy make code-flow safe without a fresh CAPTCHA.
  def turnstile_ok?
    return true if pending_login_token&.useable?
    return true if usable_login_token_for_code
    TurnstileService.verify(params.dig(:user, :turnstile_token) || params[:turnstile_token],
                            remote_ip: request.remote_ip)
  end
end
