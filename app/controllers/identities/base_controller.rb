class Identities::BaseController < ApplicationController
  def oauth
    session[:back_to] = params[:back_to] || request.referrer
    redirect_to oauth_url
  end

  def create
    if params[:error].present?
      flash[:error] = t(:'auth.oauth_cancelled')
      return redirect_to session.delete(:back_to) || dashboard_path
    end

    access_token = fetch_access_token
    return respond_with_error(401, "OAuth authorization failed") unless access_token.present?

    identity_params = fetch_identity_params(access_token)
    return respond_with_error(401, "Could not fetch user profile from OAuth provider") unless identity_params[:uid].present? && identity_params[:email].present?

    # Find or create identity by uid (the immutable SSO identifier)
    identity = Identity.find_by(identity_params.slice(:uid, :identity_type))
    
    if identity
      # Existing identity found - update its attributes (email/name may have changed in SSO)
      identity.update(identity_params)
    else
      # New identity - need to create it and link to a user
      identity = Identity.new(identity_params)
      
      if ENV['FEATURES_DISABLE_EMAIL_LOGIN']
        # SSO-only mode: uid is the source of truth
        # Try to find existing user by email (for initial account linking)
        # or create a new verified user
        identity.user = current_user.presence || User.find_by(email: identity.email)
        
        if identity.user.nil?
          # No existing user found - create new verified user for SSO
          identity.user = User.new(identity_params.slice(:name, :email).merge(email_verified: true))
          identity.user.save!
        end
      else
        # Standard mode: only link to verified users or current user
        identity.user = current_user.presence || User.verified.find_by(email: identity.email)
      end
      
      identity.save
    end

    if identity.user
      # In SSO mode, always sync user attributes from SSO provider
      identity.force_user_attrs! if ENV['LOOMIO_SSO_FORCE_USER_ATTRS']
      sign_in(identity.user)
      flash[:notice] = t(:'devise.sessions.signed_in')
    else
      session[:pending_identity_id] = identity.id
    end

    redirect_to session.delete(:back_to) || dashboard_path
  end

  def destroy
    if i = current_user.identities.find_by(identity_type: controller_name)
      i.destroy
      redirect_to request.referrer || root_path
    else
      respond_with_error 500, "Not connected to #{controller_name}!"
    end
  end

  private

  def fetch_access_token
    client = "Clients::#{controller_name.classify}".constantize.instance
    client.fetch_access_token(params[:code], redirect_uri)
  end

  def fetch_identity_params(token)
    client = "Clients::#{controller_name.classify}".constantize.new(token: token)
    client.fetch_identity_params.merge({ access_token: token, identity_type: controller_name })
  end

  def redirect_uri
    send :"#{controller_name}_authorize_url"
  end

  def oauth_url
    "#{oauth_host}?#{oauth_params.to_query}"
  end

  def oauth_host
    raise NotImplementedError.new
  end

  def oauth_params
    { client.client_key_name => client.key, redirect_uri: redirect_uri, scope: oauth_scope }
  end

  def client
    Clients::Oauth.instance
  end

  def oauth_client_id_field
    :client_id
  end

  def oauth_scope
    client.scope.join(',')
  end
end
