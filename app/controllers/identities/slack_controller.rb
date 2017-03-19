class Identities::SlackController < Identities::BaseController

  private

  def identity
    @identity ||= current_user.slack_identity
  end

  def build_identity(identity)
    identity.fetch_team_info
  end

  def oauth_url
    "https://slack.com/oauth/authorize"
  end

  def oauth_params
    super.merge(client_id: client.key, scope: "users:read,channels:read,team:read")
  end
end
