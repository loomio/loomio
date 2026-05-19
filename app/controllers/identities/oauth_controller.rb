class Identities::OauthController < Identities::BaseController

  private

  def oauth_url
    "#{oauth_auth_url}?#{oauth_params.to_query}"
  end

  def oauth_auth_url
    ENV.fetch('OAUTH_AUTH_URL')
  end

  def oauth_params
    client = Clients::Oauth.instance
    { client.client_key_name => client.key, redirect_uri: redirect_uri, scope: ENV.fetch('OAUTH_SCOPE'),  response_type: :code }
  end

  def email_verified_by_provider?(identity_params)
    return true if ActiveModel::Type::Boolean.new.cast(ENV.fetch('OAUTH_SKIP_EMAIL_VERIFIED_CHECK', false))

    ActiveModel::Type::Boolean.new.cast(identity_params[:email_verified])
  end
end
