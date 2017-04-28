class Identities::SlackController < Identities::BaseController

  def participate
    if event = ::Slack::Participator.new(participate_params).participate!
      render json: ::Slack::StanceCreatedSerializer.new(event, root: false).as_json
    else
      render json: ::Slack::RequestAuthorizationSerializer.new({}, root: false).as_json, status: :forbidden
    end
  end

  def authorized
    render template: 'slack/authorized', layout: 'application'
  end

  private

  def identity
    @identity ||= current_user.slack_identity
  end

  def complete_identity(identity)
    identity.fetch_user_info
    identity.fetch_team_info
  end

  def oauth_identity_params
    json = client.fetch_oauth(params[:code], redirect_uri).json
    {
      access_token: json['access_token'],
      uid:          json['user_id']
    }
  end

  def oauth_url
    "https://slack.com/oauth/authorize"
  end

  def participate_params
    payload = JSON.parse(params.require(:payload))
    {
      uid:     payload.dig('user', 'id'),
      poll_id: payload.dig('callback_id'),
      choice:  payload.dig('actions', 0, 'name')
    }
  end

  def oauth_params
    super.merge(client_id: client.key, scope: client.scope.join(','))
  end
end
