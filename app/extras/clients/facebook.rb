class Clients::Facebook < Clients::Base

  def fetch_access_token(code, uri)
    post "oauth/access_token", params: { code: code, redirect_uri: uri }
  end

  def fetch_user_info
    get "me?fields=id,name,email"
  end

  def fetch_permissions(uid)
    get "#{uid}/permissions", options: {
      failure:    ->(response) { { error: "User has not granted all needed permissions" } },
      is_success: ->(response) {
        response.success? &&
        (scope - JSON.parse(response.body)['data'].map { |p| p['permission'] if p['status'] == 'granted' }).empty? } }
  end

  def fetch_user_avatar(uid)
    get "#{uid}/picture?redirect=false&type=normal", options: {
      success: ->(response) { response['data']['url'] } }
  end

  def fetch_admin_groups(uid)
    get "#{uid}/groups", options: {
      success: ->(response) { response['data'] } }
  end

  def is_member_of?(group_id, uid)
    get "#{group_id}/members", options: {
      success: ->(response) { response['data'].any? { |member| member['id'] == uid } } }
  end

  def post_content!(event)
    post "#{event.community.identifier}/feed", params: serialized_event(event), options: {
      success: ->(response) { response['id'] } }
  end

  # NB: this switch sucks, but it's too early to extract to something else
  def scope
    %w(email).freeze
  end

  def client_key_name
    :app_id
  end

  private

  def token_name
    :access_token
  end

  def default_host
    "https://graph.facebook.com/v2.8".freeze
  end
end
