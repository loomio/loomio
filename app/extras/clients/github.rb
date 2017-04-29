class Clients::Github < Clients::Base

  def fetch_access_token(code, uri)
    post "login/oauth/access_token",
      params:  { code: code, redirect_uri: uri },
      options: { host: "https://github.com" }
  end

  def fetch_user_info
    get "user"
  end

  def scope
    %w(user:email).freeze
  end

  private

  def default_headers
    { 'Accept' => 'application/json', 'User-Agent' => ENV['GITHUB_APP_NAME'] }
  end

  def token_name
    :access_token
  end

  def default_host
    "https://api.github.com".freeze
  end
end
