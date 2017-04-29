class Identities::TwitterController < Identities::BaseController

  private

  def oauth_host
    "https://api.twitter.com/oauth/request_token"
  end

  def oauth_params
    { redirect_uri: redirect_uri, oauth_consumer_key: client.key }
  end
end
