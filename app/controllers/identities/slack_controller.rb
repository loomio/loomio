class Identities::SlackController < Identities::BaseController

  def participate
    if event = ::Slack::Participator.new(participate_params).participate!
      render json: ::Slack::StanceCreatedSerializer.new(event, root: false).as_json
    else
      respond_with_unauthorized
    end
  end

  def initiate
    if url = ::Slack::Initiator.new(initiate_params).initiate!
      render text: I18n.t(:"slack.initiate", type: initiate_params[:type], url: url)
    else
      respond_with_unauthorized
    end
  end

  def authorized
    render template: 'slack/authorized', layout: 'application'
  end

  private

  def respond_with_unauthorized
    render json: ::Slack::RequestAuthorizationSerializer.new({}, root: false).as_json, status: :forbidden
  end

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
    @participate_params ||= {
      uid:     payload.dig('user', 'id'),
      poll_id: payload.dig('callback_id'),
      choice:  payload.dig('actions', 0, 'name')
    }
  end

  def initiate_params
    @initiate_params ||= {
      uid:   payload.dig('user_id'),
      title: payload.dig('text'),
      type:  payload.dig('command').split('_').last
    }
  end

  def payload
    @payload ||= JSON.parse(params.require(:payload))
  end

  def oauth_params
    super.merge(client_id: client.key, scope: client.scope.join(','))
  end
end
