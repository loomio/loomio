class Clients::Google < Clients::Base

  def fetch_access_token(code, uri)
    post "token", params: { code: code, redirect_uri: uri, grant_type: :authorization_code }
  end

  def fetch_user_info
    get "userinfo", options: { host: :"https://www.googleapis.com/oauth2/v2" }
  end

  def scope
    %w(email profile).freeze
  end

  private

  def default_headers
    { 'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8' }
  end

  def token_name
    :oauth_token
  end

  def default_host
    "https://www.googleapis.com/oauth2/v4".freeze
  end
end
