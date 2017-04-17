class Clients::Facebook < Clients::Base

  def fetch_oauth(code, uri)
    post "oauth/access_token", { code: code, redirect_uri: uri }
  end


  def fetch_user_info
    get "me"
  end

  def fetch_permissions(uid)
    get "#{uid}/permissions", {}, default_success, permissions_missing, has_all_permissions?
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

  def post_content!(event)
    post "#{event.community.identifier}/feed", serialized_event(event), ->(response) { response['id'] }
  end

  def scope
    %w(user_managed_groups publish_actions).freeze
  end

  private

  def permissions_missing
    ->(response) { { error: "User has not granted all needed permissions" } }
  end

  def has_all_permissions?
    ->(response) {
      response.success? &&
      (scope - JSON.parse(response.body)['data'].map { |p| p['permission'] if p['status'] == 'granted' }).empty?
    }
  end

  def token_name
    :access_token
  end

  def host
    "https://graph.facebook.com/v2.8".freeze
  end
end
