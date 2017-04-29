class Identities::GoogleController < Identities::BaseController

  private

  def oauth_url
    super.gsub("%2B", "+")
  end

  def oauth_host
    "https://accounts.google.com/o/oauth2/v2/auth"
  end

  def oauth_params
    {
      redirect_uri: redirect_uri,
      client_id: client.key,
      scope: client.scope.join('+'),
      response_type: :code
    }
  end
end
