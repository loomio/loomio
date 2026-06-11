module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :user_signed_in? if respond_to?(:helper_method)
  end

  # ── sign in ──────────────────────────────────────────────────────────
  def sign_in(user)
    user = UserService.verify(user: user)

    # Create Rails session record
    session_record = user.sessions.create!(
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )
    cookies.signed.permanent[:session_token] = {
      value: session_record.token,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax
    }
    cookies[:signed_in] = 1

    # Transitional: also keep Warden session while migrating
    warden.set_user(user, scope: :user) if defined?(warden)

    @current_user = user

    true
  end

  # ── sign out ─────────────────────────────────────────────────────────
  def sign_out
    if (token = cookies.signed[:session_token])
      Session.find_by(token: token)&.destroy
    end
    cookies.delete(:session_token)
    cookies.delete(:signed_in)

    # Transitional: also clear Warden
    warden.logout if defined?(warden)

    @current_user = nil
  end

  # ── current user ─────────────────────────────────────────────────────
  def current_user
    @current_user ||= find_user_from_session || find_user_from_warden || build_guest_user
  end

  # ── authentication gates ─────────────────────────────────────────────
  def user_signed_in?
    current_user.is_logged_in?
  end

  def authenticate_user!
    unless user_signed_in?
      respond_to do |format|
        format.html { redirect_to dashboard_path }
        format.json { render json: { error: 'Unauthorized' }, status: 401 }
      end
    end
  end

  def require_current_user
    respond_with_error(401) unless current_user && current_user.is_logged_in?
  end

  private

  def find_user_from_session
    token = cookies.signed[:session_token]
    return unless token

    session_record = Session.find_by(token: token)
    return unless session_record&.user

    if session_record.expired?
      session_record.destroy
      return nil
    end

    session_record.record_activity!
    session_record.user
  end

  # Transitional: detects Warden-authenticated users and creates a
  # Rails Session record for them. After the migration period both
  # the Warden session AND the Rails session exist, but subsequent
  # requests use the Rails session. Remove this method once migration
  # is complete.
  def find_user_from_warden
    return unless defined?(warden) && warden.authenticated?(:user)

    user = warden.user(:user)
    return unless user

    # Create a Rails Session so the next request uses it
    session_record = user.sessions.create!(
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )
    cookies.signed.permanent[:session_token] = {
      value: session_record.token,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax
    }
    cookies[:signed_in] = 1
    user
  end

  def build_guest_user
    LoggedOutUser.new(locale: logged_out_preferred_locale, params: params, session: session)
  end
end
