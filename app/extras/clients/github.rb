class Clients::Github < Clients::Base

  def fetch_oauth(code, uri)
    post "login/oauth/access_token", { host: "https://github.com", code: code, redirect_uri: uri }
  end

  def fetch_user_info
    get "user", {}
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

  def host
    "https://api.github.com".freeze
  end
end
