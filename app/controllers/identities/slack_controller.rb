class Identities::SlackController < Identities::BaseController

  private

  def identity
    @identity ||= current_user.slack_identity
  end

  def complete_identity(identity)
    identity.fetch_user_info
    identity.fetch_team_info
  end

  def oauth_identity_params
    response = Hash(client.fetch_oauth(params[:code], redirect_uri))
    {
      access_token: response['access_token'],
      uid:          response['user_id']
    }
  end

  def oauth_url
    "https://slack.com/oauth/authorize"
  end

  def oauth_params
    super.merge(client_id: client.key, scope: client.scope)
  end
end
