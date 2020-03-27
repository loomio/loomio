class Identities::NextcloudController < Identities::BaseController

  private

  def oauth_host
    ENV['NEXTCLOUD_HOST']
  end

  def oauth_url
    "#{oauth_host}#{oauth_authorize_path}?#{oauth_params.to_query}"
  end

  def oauth_authorize_path
    '/index.php/apps/oauth2/authorize'.freeze
  end

  def oauth_params
    { client.client_key_name => client.key, redirect_uri: redirect_uri, response_type: :code }
  end
end
