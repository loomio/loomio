class Clients::Google < Clients::Base

  def fetch_oauth(code, uri)
    post "token",
      params: { code: code, redirect_uri: uri, grant_type: :authorization_code },
      options: { host: :"https://www.googleapis.com/oauth2/v4" }
  end

  def fetch_user_info
    get "people/me"
  end

  def scope
    %w(email profile).freeze
  end

  private

  def token_name
    :oauth_token
  end

  def default_host
    "https://people.googleapis.com/v1".freeze
  end
end
