module OmniauthAuthenticationHelper
  def omniauth_authenticated_and_waiting?
    if session.has_key?(:omniauth_identity_id)
      load_omniauth_authentication_from_session
    else
      false
    end
  end

  def load_omniauth_authentication_from_session
    @omniauth_authentication = OmniauthIdentity.find(session[:omniauth_identity_id]) if session[:omniauth_identity_id]
  end

  def link_omniauth_authentication_to_current_user
    load_omniauth_authentication_from_session
    @omniauth_authentication.user = current_user
    @omniauth_authentication.save!
    clear_omniauth_authentication_from_session
  end

  def save_omniauth_authentication_to_session(auth)
    session[:omniauth_identity_id] = auth.id
  end

  def clear_omniauth_authentication_from_session
    session.delete(:omniauth_identity_id)
  end

  def check_for_omniauth_authentication
    if omniauth_authenticated_and_waiting?
      link_omniauth_authentication_to_current_user
    end
  end
end
