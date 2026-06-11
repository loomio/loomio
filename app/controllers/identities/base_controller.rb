class Identities::BaseController < ApplicationController
  def oauth
    session[:back_to] = safe_back_to
    session[:oauth_state] = SecureRandom.hex(32)
    redirect_to oauth_url
  end

  def create
    return respond_with_error(401, "OAuth state mismatch") unless valid_oauth_state?

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
    flash[:notice] = t(:'auth.signed_in')

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
    {
      client.client_key_name => client.key,
      redirect_uri: redirect_uri,
      scope: oauth_scope,
      state: session[:oauth_state]
    }
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

  def safe_back_to
    path = (params[:back_to] || request.referrer).to_s
    path if path.start_with?('/') && !path.start_with?('//', '/\\')
  end

  def valid_oauth_state?
    expected_state = session.delete(:oauth_state).to_s
    returned_state = params[:state].to_s
    return false if expected_state.blank? || returned_state.blank?

    ActiveSupport::SecurityUtils.secure_compare(expected_state, returned_state)
  end
end
