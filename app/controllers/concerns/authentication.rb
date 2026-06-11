module Authentication
  extend ActiveSupport::Concern

  DEVISE_SESSION_KEY = "warden.user.user.key"

  def sign_in(user)
    @current_user = nil
    session_record = user.sessions.create!(
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )
    session.delete(DEVISE_SESSION_KEY)
    session[:session_token] = session_record.token
    cookies[:signed_in] = { value: 1, httponly: false }
    user
  end

  def sign_out
    if (token = session.delete(:session_token))
      Session.find_by(token: token)&.destroy
    end
    session.delete(DEVISE_SESSION_KEY)
    @current_user = nil
    cookies.delete(:signed_in)
  end

  def require_authentication
    respond_with_error(401) unless current_user.is_logged_in?
  end

  private

  def resume_session
    if (token = session[:session_token])
      s = Session.find_by(token: token)
      return nil unless s
      return nil if s.user.deactivated_at?
      return s.user
    end

    # Seamlessly migrate existing Devise/Warden sessions. Warden stores
    # [[user_id], authenticatable_salt] where salt = password_digest[0..29].
    # We verify the salt still matches (catches password-changed invalidation),
    # then swap the Devise session entry for a real Session record.
    if (devise_key = session[DEVISE_SESSION_KEY])
      user_id = devise_key.dig(0, 0)
      salt    = devise_key[1]
      user    = User.active.verified.find_by(id: user_id)
      if user && user.password_digest.present? && ActiveSupport::SecurityUtils.secure_compare(user.password_digest[0, 30], salt.to_s)
        sign_in(user)
        return user
      else
        session.delete(DEVISE_SESSION_KEY)
      end
    end

    nil
  end
end
