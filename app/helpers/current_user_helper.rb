module CurrentUserHelper
  include PendingActionsHelper

  ACCOUNT_COMPLETION_TTL = 15.minutes

  class SpamUserDeniedError < StandardError
  end

  class InactiveUserError < StandardError
  end

  def sign_in(user, handle_pending: true)
    @current_user = nil
    require_active_user!(user)
    user = UserService.verify(user: user)
    # Verification can resolve a provisional user to another verified account.
    require_active_user!(user)
    require_user_name!(user)
    start_new_session_for(user)
    record_successful_sign_in(user)
    discard_account_completion
    handle_pending_actions(user) if handle_pending
    user
  end

  def sign_out(_scope = nil)
    terminate_session
    discard_account_completion
    PasskeyService.discard_challenge!(session, PasskeyService::CHALLENGE_REGISTRATION)
    PasskeyService.discard_challenge!(session, PasskeyService::CHALLENGE_AUTHENTICATION)
    reset_session
    @current_user = nil
    true
  end

  def stage_account_completion(user, name_managed: false)
    require_active_user!(user)
    discard_account_completion
    AccountCompletionProof.where(expires_at: ..Time.current).delete_all
    proof = AccountCompletionProof.create!(user: user, name_managed: name_managed, expires_at: ACCOUNT_COMPLETION_TTL.from_now)
    session[:pending_account_completion] = {
      proof_id: proof.id,
      user_id: user.id,
      name_managed: name_managed
    }
  end

  def pending_account_completion_proof
    pending = session[:pending_account_completion]
    proof_id = pending && (pending['proof_id'] || pending[:proof_id])
    AccountCompletionProof.find_by(id: proof_id) if proof_id
  end

  def discard_account_completion
    pending_account_completion_proof&.destroy!
    session.delete(:pending_account_completion)
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

  def authentication_return_path(fallback: nil)
    session.delete(:return_to_after_authenticating) || session.delete(:back_to) || fallback
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

  def require_active_user!(user)
    raise InactiveUserError unless user.active?
  end

  # A session must never expose an incomplete profile to the application.
  # Authentication entry points complete or reject nameless accounts first;
  # this shared boundary prevents a new entry point from bypassing that rule.
  def require_user_name!(user)
    return if user.name.present?

    user.errors.add(:name, :blank)
    raise ActiveRecord::RecordInvalid, user
  end

  def authenticated_user
    resume_session&.user
  end

  def resume_session
    return Current.session if Current.session&.user&.active?

    Current.session = find_session_by_cookie
  end

  def find_session_by_cookie
    return unless cookies.signed[:session_id]

    session_record = Session.includes(:user).find_by(id: cookies.signed[:session_id])
    return session_record if session_record&.user&.active?

    session_record&.destroy!
    nil
  end

  def start_new_session_for(user)
    terminate_session if Current.session

    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session_record|
      Current.session = session_record
      cookies.signed.permanent[:session_id] = {
        value: session_record.id,
        httponly: true,
        same_site: :lax,
        secure: Rails.application.config.force_ssl
      }
      cookies.permanent[:signed_in] = {
        value: '1',
        same_site: :lax,
        secure: Rails.application.config.force_ssl
      }
    end
  end

  def terminate_session
    Current.session&.destroy
    Current.session = nil
    cookies.delete(:session_id)
    cookies.delete(:signed_in)
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
