class Clients::Facebook < Clients::Base

  def fetch_access_token(code, uri)
    post("oauth/access_token", code: code, redirect_uri: uri) { |response| response['access_token'] }
  end

  def fetch_user_info
    get("me") { |response| response }
  end

  def fetch_user_avatar(uid)
    get("#{uid}/picture?redirect=false") { |response| response.dig('data', 'url') }
  end

  def fetch_admin_groups(uid)
    get("#{uid}/groups") { |response| response['data'] }
  end

  private

  def token_name
    :access_token
  end

  def host
    "https://graph.facebook.com/v2.8".freeze
  end
end
