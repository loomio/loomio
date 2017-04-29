class Clients::Twitter < Clients::Base

  def fetch_oauth(code, uri)
    post "oauth/authorize", params: { code: code, redirect_uri: uri }
  end

  def fetch_user_info
    get "user"
  end

  private

  def token_name
    :oauth_token
  end

  def host
    "https://api.twitter.com".freeze
  end
end
