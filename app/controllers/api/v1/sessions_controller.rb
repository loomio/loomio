class Api::V1::SessionsController < ApplicationController
  include PrettyUrlHelper

  def create
    unless turnstile_ok?
      render json: { errors: { turnstile: [I18n.t('auth_form.turnstile_required')] } }, status: 403
      return
    end
    if user = attempt_login
      sign_in(user)
      flash[:notice] = t(:'sessions.signed_in', default: 'Signed in')
      user.update(name: resource_params[:name]) if resource_params[:name]
      user.update_columns(bounces_count: 0, complaints_count: 0) if user.bounces_count > 0 || user.complaints_count > 0
      render json: Boot::User.new(user, root_url: URI(root_url).origin).payload
      EventBus.broadcast('session_create', user)
    else
      render json: { errors: failure_message }, status: 401
    end
    session.delete(:pending_login_token)
  end

  def destroy
    current_user.update_columns(secret_token: UUIDTools::UUID.random_create.to_s) if current_user.is_logged_in?
    sign_out

    flash[:notice] = t(:'sessions.signed_out', default: 'Signed out')
    respond_to do |format|
      format.html { redirect_to dashboard_path }
      format.json { render json: { success: :ok } }
    end
  end

  private

  def failure_message
    if resource_params[:password] && login_user&.access_locked?
      { password: [I18n.t('auth_form.account_locked')] }
    elsif session[:pending_login_token].present?
      { token: [I18n.t('auth_form.invalid_token')] }
    elsif resource_params[:password] && login_user.nil?
      { email: [I18n.t('auth_form.email_not_found')] }
    else
      { password: [I18n.t('auth_form.invalid_password')] }
    end
  end

  def login_user
    @login_user ||= User.find_for_authentication(email: resource_params[:email])
  end

  def attempt_login
    if pending_login_token&.useable?
      pending_login_token.user
    elsif resource_params[:code]
      login_token_user
    else
      login_user if login_user&.authenticate_for_session(resource_params[:password], request: request)
    end
  end

  def login_token_user
    LoginToken.transaction do
      token = LoginToken.unused.lock.find_by(code: resource_params.require(:code))
      next unless login_token_matches?(token)

      token.update!(used: true)
      token.user
    end
  end

  def login_token_matches?(token)
    resource_params[:email].present? && token&.useable? && token.user.email == resource_params[:email]
  end

  def usable_login_token_for_code
    return unless resource_params[:code].present?

    token = LoginToken.unused.find_by(code: resource_params[:code])
    if login_token_matches?(token)
      token
    else
      record_failed_login_code_attempt
      nil
    end
  end

  def record_failed_login_code_attempt
    return if resource_params[:email].blank?

    LoginToken.transaction do
      user = User.find_by(email: resource_params[:email])
      token = user&.login_tokens&.unused&.lock&.order(created_at: :desc)&.find(&:useable?)
      token&.record_failed_code_attempt!
    end
  end

  def resource_params
    params.fetch(:user, {}).permit(:code, :email, :password, :remember_me, :turnstile_token)
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
