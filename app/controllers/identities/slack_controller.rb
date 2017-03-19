class Identities::SlackController < Identities::BaseController

  private

  def identity
    @identity ||= current_user.slack_identity
  end

  def build_identity
    Identities::Slack.new(client.get("oauth.access", { code: params[:code], redirect_uri: redirect_uri }) do |response|
      {
        access_token:  response['access_token'],
        slack_team_id: response['team_id'],
        uid:           response['user_id']
      }
    end)
  end

  def oauth_url
    "https://slack.com/oauth/authorize"
  end

  def oauth_params
    super.merge(client_id: client.key, scope: "users:read,channels:read")
  end
end
