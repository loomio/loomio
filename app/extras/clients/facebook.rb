class Clients::Facebook < Clients::Base
  include Routing

  def post_poll_button(recipient_id)
    post "me/messages?access_token=#{ENV['FACEBOOK_APP_PAGE_TOKEN']}", params: {
      messaging_type: :RESPONSE,
      recipient: { id: recipient_id },
      message: button_message(
        url: "#{https_host}/facebook/webview",
        title: "Open webview"
      )
    }
  end

  def set_messenger_profile
    post "me/messenger_profile?access_token=#{ENV['FACEBOOK_APP_PAGE_TOKEN']}", params: {
      get_started: { payload: "test" },
      home_url: {
        url: "#{https_host}/facebook/webview",
        webview_height_ratio: :tall,
        webview_share_button: :show,
        in_test: true
      },
      account_linking_url: "#{https_host}/facebook/oauth",
      whitelisted_domains: [https_host],
      persistent_menu: [{
        locale: :default,
        composer_input_disabled: true,
        call_to_actions: [
          {
            title: "Start a poll",
            type: :nested,
            call_to_actions: AppConfig.poll_templates.keys[0..4].map do |poll_type|
              {
                type: :web_url,
                url: "#{https_host}/facebook/webview?poll_type=#{poll_type}",
                title: poll_type,
                messenger_extensions: true
              }
            end
          }
        ]
      }]
    }
  end

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

  def scope
    %w(email).freeze
  end

  def client_key_name
    :app_id
  end

  private

  def button_message(url:, type: :web_url, title: nil, messenger_extensions: true)
    {
      attachment: {
        type: :template,
        payload: {
          template_type: :generic,
          elements: [
            title: "Open a webview",
            buttons: [{
              url:   url,
              type:  type,
              title: title,
              messenger_extensions: messenger_extensions
            }]
          ]
        }
      }
    }
  end

  def https_host
    "https://d2e720c4.ngrok.io"
  end

  def token_name
    :access_token
  end

  def default_host
    "https://graph.facebook.com/v2.11".freeze
  end
end
