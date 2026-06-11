class Api::V1::SessionsController < Api::V1::RestfulController
  include PrettyUrlHelper

  def create
    unless turnstile_ok?
      render json: { errors: { turnstile: [I18n.t('auth_form.turnstile_required')] } }, status: 403
      return
    end
    if user = attempt_login
      sign_in(user)
      flash[:notice] = t(:'devise.sessions.signed_in')
      user.update(name: session_params[:name]) if session_params[:name]
      user.update_columns(bounces_count: 0, complaints_count: 0) if user.bounces_count > 0 || user.complaints_count > 0
      render json: Boot::User.new(user, root_url: URI(root_url).origin).payload
      EventBus.broadcast('session_create', user)
    else
      render json: { errors: failure_message }, status: 401
    end
    session.delete(:pending_login_token)
  end

  def destroy
    current_user.update_columns(secret_token: UUIDTools::UUID.random_create.to_s)
    sign_out

    flash[:notice] = t(:'devise.sessions.signed_out')
    render json: { success: :ok }
  end

  private

  def session_params
    params.require(:user).permit(:email, :password, :code, :name, :remember_me, :turnstile_token)
  rescue ActionController::ParameterMissing
    params.permit(:email, :password, :code, :name, :remember_me, :turnstile_token)
  end

  def failure_message
    if session_params[:password] && login_user&.access_locked?
      { password: [I18n.t('auth_form.account_locked')] }
    elsif session[:pending_login_token].present?
      { token: [I18n.t('auth_form.invalid_token')] }
    elsif session_params[:password] && login_user.nil?
      { email: [I18n.t('auth_form.email_not_found')] }
    else
      { password: [I18n.t('auth_form.invalid_password')] }
    end
  end

  def login_user
    @login_user ||= User.find_by_email_for_authentication(session_params[:email])
  end

  def attempt_login
    if pending_login_token&.useable?
      pending_login_token.user
    elsif session_params[:code]
      login_token_user
    else
      authenticate_with_password
    end
  end

  def authenticate_with_password
    user = login_user
    return nil unless user&.active_for_authentication?

    if user.access_locked?
      nil
    elsif user.authenticate(session_params[:password])
      user.reset_failed_attempts
      user
    else
      user.increment_failed_attempts
      nil
    end
  end

  def login_token_user
    LoginToken.transaction do
      token = LoginToken.unused.lock.find_by(code: session_params.require(:code))
      next unless login_token_matches?(token)

      token.update!(used: true)
      token.user
    end
  end

  def login_token_matches?(token)
    session_params[:email].present? && token&.useable? && token.user.email == session_params[:email]
  end

  def usable_login_token_for_code
    return unless session_params[:code].present?

    token = LoginToken.unused.find_by(code: session_params[:code])
    if login_token_matches?(token)
      token
    else
      record_failed_login_code_attempt
      nil
    end
  end

  def record_failed_login_code_attempt
    return if session_params[:email].blank?

    LoginToken.transaction do
      user = User.find_by(email: session_params[:email])
      token = user&.login_tokens&.unused&.lock&.order(created_at: :desc)&.find(&:useable?)
      token&.record_failed_code_attempt!
    end
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
