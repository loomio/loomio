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

    identity = IdentityService.link_or_create(
      identity_params: identity_params,
      current_user: current_user
    )

    # Handle pending identity flow (user is switching accounts)
    if !identity.user
      back_to = session[:back_to]
      sign_out
      session[:pending_identity_id] = identity.id
      flash[:notice] = t(:'auth.switching_accounts')
      return redirect_to back_to || dashboard_path
    end

    # Handle successful login
    sign_in(identity.user)
    flash[:notice] = t(:'devise.sessions.signed_in')

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
