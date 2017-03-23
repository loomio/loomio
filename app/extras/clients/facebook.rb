class Clients::Facebook < Clients::Base

  def fetch_oauth(code, uri)
    post("oauth/access_token", code: code, redirect_uri: uri) { |response| response }
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

  def is_member_of?(group_id, uid)
    get("#{group_id}/members") do |response|
      response['data'].any? { |member| member['id'] == uid }
    end
  end

  private

  def token_name
    :access_token
  end

  def host
    "https://graph.facebook.com/v2.8".freeze
  end
end
