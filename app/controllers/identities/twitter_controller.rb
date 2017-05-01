class Identities::TwitterController < Identities::BaseController

  private

  def complete_identity(identity)
    identity.fetch_user_info
  end

  def oauth_url
    "https://api.twitter.com/oauth/request_token"
  end

  def oauth_params
    super.merge(oauth_consumer_key: client.key)
  end
end
