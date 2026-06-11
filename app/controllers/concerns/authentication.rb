module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :resume_session
    helper_method :authenticated?, :user_signed_in?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :resume_session, **options
    end
  end

  def authenticate_user!
    resume_session
    return if authenticated?

    respond_to do |format|
      format.html { redirect_to dashboard_path }
      format.json { render json: { error: I18n.t("errors.401.title") }, status: :unauthorized }
      format.any { head :unauthorized }
    end
  end

  def authenticated?
    Current.user.present?
  end
  alias_method :user_signed_in?, :authenticated?

  def current_user
    Current.user
  end

  def sign_in(user)
    start_new_session_for(user)
  end

  def sign_out(_scope = nil)
    terminate_session
  end

  private

  def resume_session
    Current.session ||= find_session_by_cookie || migrate_devise_session
  end

  def find_session_by_cookie
    Session.includes(:user).find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  def migrate_devise_session
    user = user_from_devise_session
    return unless user

    start_new_session_for(user)
    session.delete('warden.user.user.key')
    Current.session
  end

  def user_from_devise_session
    key = session['warden.user.user.key']
    return unless key.is_a?(Array)

    id = Array(key.first).first
    salt = key.second
    user = User.find_by(id: id)
    user if user&.authenticatable_salt == salt
  end

  def start_new_session_for(user)
    terminate_session
    Current.session = user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip)
    cookies.signed.permanent[:session_id] = { value: Current.session.id, httponly: true, same_site: :lax }
    cookies[:signed_in] = 1
    true
  end

  def terminate_session
    Current.session&.destroy
    Current.session = nil
    cookies.delete(:session_id)
    cookies.delete(:signed_in)
  end
end
