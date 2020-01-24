class Clients::Slack < Clients::Base

  def fetch_access_token(code, uri)
    get "oauth.access", params: { code: code, redirect_uri: uri }
  end

  def fetch_user_info
    get "users.profile.get", options: { success: ->(response) { response['profile'] } }
  end

  def fetch_team_info
    get "team.info", options: { success: ->(response) { response['team'] } }
  end

  # We are doing two requests and combining them here
  def fetch_channels
    channels = get "conversations.list", params: {types: "public_channel,private_channel", limit: 1000}, options: { success: ->(response) { response['channels'] } }

    json = if channels.success
      [channels].map(&:json).flatten.reject {|channel| channel['name'].starts_with?("mpdm-") }
    else
      []
    end
    OpenStruct.new(json: json)
  end

  def post_content!(event)
    get "chat.postMessage", params: serialized_event(event)
  end

  def is_member_of?(channel_id, uid)
    get "channels.info", params: { channel: channel_id }, options: {
      success: ->(response) { Array(response['channel']['members']).include?(uid) } }
  end

  def scope
    %w(users.profile:read channels:read groups:read team:read chat:write:bot commands)
  end

  private

  def default_is_success
    ->(response) { response.success? && JSON.parse(response.body)['ok'].present? }
  end

  def default_host
    "https://slack.com/api".freeze
  end
end
