class Clients::Twitter < Clients::Base

  def fetch_access_token(code, uri)
    post "oauth/authorize", params: { code: code, redirect_uri: uri }
  end

  def fetch_user_info
    get "user"
  end

  private

  def token_name
    :oauth_token
  end

  def default_host
    "https://api.twitter.com".freeze
  end
end
