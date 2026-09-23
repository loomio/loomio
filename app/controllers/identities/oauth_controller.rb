class Identities::OauthController < Identities::BaseController
  private

  def oauth_url
    "#{oauth_auth_url}?#{oauth_params.to_query}"
  end

  def oauth_auth_url
    AppConfig.oauth_authorization_url
  end

  def oauth_params
    client = Clients::Oauth.instance
    {
      client.client_key_name => client.key,
      redirect_uri: redirect_uri,
      scope: AppConfig.oauth_scope,
      response_type: :code,
      state: session[:oauth_state]
    }
  end
end
