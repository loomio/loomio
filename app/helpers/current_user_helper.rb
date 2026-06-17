module CurrentUserHelper
  include PendingActionsHelper

  class SpamUserDeniedError < StandardError
  end

  def sign_in(user)
    @current_user = nil
    user = UserService.verify(user: user)
    start_new_session_for(user)
    record_successful_sign_in(user)
    handle_pending_actions(user)
    user
  end

  def sign_out(_scope = nil)
    terminate_session
    @current_user = nil
    true
  end

  def current_user
    @current_user ||= authenticated_user || LoggedOutUser.new(locale: logged_out_preferred_locale, params: params, session: session)
  end

  def authenticate_user!
    return true if current_user.is_logged_in?

    session[:return_to_after_authenticating] = request.fullpath if request.request_method == 'GET'
    redirect_to dashboard_path
    false
  end

  def deny_spam_users
    if NoSpam::SPAM_REGEX.match?(current_user.email)
      raise SpamUserDeniedError.new(current_user.email)
    end
  end

  def require_current_user
    respond_with_error(401) unless current_user && current_user.is_logged_in?
  end

  private

  def authenticated_user
    resume_session&.user || bridge_devise_session&.user
  end

  def resume_session
    return Current.session if Current.session&.user&.active_for_authentication?

    Current.session = find_session_by_cookie
  end

  def find_session_by_cookie
    return unless cookies.signed[:session_id]

    Session.includes(:user).find_by(id: cookies.signed[:session_id]).tap do |session_record|
      session_record&.destroy unless session_record&.user&.active_for_authentication?
    end
  end

  def bridge_devise_session
    user = bridged_devise_user
    return unless user&.active_for_authentication?

    start_new_session_for(user).tap do
      session.delete('warden.user.user.key')
    end
  end

  def bridged_devise_user
    key = session['warden.user.user.key']
    user_id = Array(key).dig(0, 0)
    User.find_by(id: user_id) if user_id
  end

  def start_new_session_for(user)
    terminate_session if Current.session

    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session_record|
      Current.session = session_record
      cookies.signed.permanent[:session_id] = {
        value: session_record.id,
        httponly: true,
        same_site: :lax,
        secure: ENV['FORCE_SSL'].to_i == 1
      }
      cookies.permanent[:signed_in] = {
        value: '1',
        same_site: :lax,
        secure: ENV['FORCE_SSL'].to_i == 1
      }
    end
  end

  def terminate_session
    Current.session&.destroy
    Current.session = nil
    cookies.delete(:session_id)
    cookies.delete(:signed_in)
    session.delete('warden.user.user.key')
  end

  def record_successful_sign_in(user)
    user.update_columns(
      sign_in_count: user.sign_in_count.to_i + 1,
      last_sign_in_at: user.current_sign_in_at,
      current_sign_in_at: Time.current,
      last_sign_in_ip: user.current_sign_in_ip,
      current_sign_in_ip: request.remote_ip,
      failed_attempts: 0,
      locked_at: nil
    )
  end

  def restricted_user
    User.find_by!(params.slice(:unsubscribe_token).permit!).tap { |user| user.restricted = true } if params[:unsubscribe_token]
  end

  def set_last_seen_at
    current_user.update_attribute :last_seen_at, Time.now
  end
end
