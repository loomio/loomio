module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :authenticated?
  end

  private

  def authenticated?
    Current.session.present?
  end

  def authenticate_user!
    redirect_to dashboard_path unless authenticated?
  end

  def resume_session
    Current.session ||= find_session_by_cookie || migrate_devise_session!
  end

  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  def migrate_devise_session!
    return unless session[:"warden.user.user.key"].present?

    user_id = Array(session[:"warden.user.user.key"]).first&.first
    return unless user_id

    user = User.find_by(id: user_id)
    return unless user

    new_session = user.sessions.create!(
      user_agent: request.user_agent,
      ip_address: request.remote_ip
    )
    Current.session = new_session
    cookies.signed.permanent[:session_id] = { value: new_session.id, httponly: true, same_site: :lax }
    session.delete(:"warden.user.user.key")
    new_session
  end

  def start_new_session_for(user)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      Current.session = session
      cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      cookies.signed[:signed_in] = 1
      update_trackable!(user)
    end
  end

  def terminate_session
    Current.session&.destroy
    cookies.delete(:session_id)
    cookies.delete(:signed_in)
  end

  def update_trackable!(user)
    user.update_columns(
      last_sign_in_at: user.current_sign_in_at,
      current_sign_in_at: Time.current,
      last_sign_in_ip: user.current_sign_in_ip,
      current_sign_in_ip: request.remote_ip,
      sign_in_count: user.sign_in_count + 1
    )
  end
end
