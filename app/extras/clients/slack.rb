class Clients::Slack < Clients::Base

  def fetch_access_token(code, uri)
    get("oauth.access", code: code, redirect_uri: uri) { |response| response }
  end

  def fetch_team_info
    get("team.info") { |response| response['team'] }
  end

  def fetch_channels
    get("channels.list") { |response| response['channels'] }
  end

  private

  def host
    "https://slack.com/api".freeze
  end
end
