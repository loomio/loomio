class Clients::Slack < Clients::Base

  def fetch_oauth(code, uri)
    get "oauth.access", { code: code, redirect_uri: uri }
  end

  def fetch_user_info(id)
    get "users.info", { user: id }, ->(response) { response['user'] }
  end

  def fetch_team_info
    get "team.info", {}, ->(response) { response['team'] }
  end

  def fetch_channels
    get "channels.list", {}, ->(response) { response['channels'] }
  end

  def post_content!(event)
    get "chat.postMessage", serialized_event(event)
  end

  def is_member_of?(channel_id, uid)
    get "channels.info", { channel: channel_id }, ->(response) { Array(response['channel']['members']).include?(uid) }
  end

  def scope
    %w(users:read channels:read team:read chat:write:bot commands).freeze
  end

  private

  def default_is_success
    ->(response) { response.success? && JSON.parse(response.body)['ok'].present? }
  end

  def host
    "https://slack.com/api".freeze
  end
end
