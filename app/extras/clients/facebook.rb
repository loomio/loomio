class Clients::Facebook < Clients::Base

  def fetch_oauth(code, uri)
    post "oauth/access_token", { code: code, redirect_uri: uri }
  end

  def fetch_user_info
    get "me"
  end

  def fetch_user_avatar(uid)
    get "#{uid}/picture?redirect=false", {}, ->(response) { response['data']['url'] }
  end

  def fetch_admin_groups(uid)
    get "#{uid}/groups", {}, ->(response) { response['data'] }
  end

  def is_member_of?(group_id, uid)
    get "#{group_id}/members", {}, ->(response) { response['data'].any? { |member| member['id'] == uid } }
  end

  def post_content(event, group_id)
    post "#{group_id}/feed", {}, serialized_event(event), ->(response) { response['id'] }
  end

  def scope
    "user_managed_groups,publish_actions"
  end

  private

  def token_name
    :access_token
  end

  def host
    "https://graph.facebook.com/v2.8".freeze
  end
end
