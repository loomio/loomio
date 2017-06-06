class Identities::SlackController < Identities::BaseController
  before_filter :respond_with_ok, only: [:participate, :initiate]
  include Identities::Slack::Install
  include Identities::Slack::Initiate
  include Identities::Slack::Participate

  def authorized
    @team = params[:team]
    render template: 'slack/authorized', layout: 'application'
  end

  private

  def respond_with_ok
    head :ok if params[:ssl_check].present?
  end

  def respond_with_unauthorized(team)
    ::Slack::Ephemeral::RequestAuthorizationSerializer.new(team, root: false).as_json
  end

  def complete_identity(identity)
    super
    identity.fetch_team_info
  end

  def identity_params
    json = client.fetch_access_token(params[:code], redirect_uri).json
    {
      access_token: json['access_token'],
      uid:          json['user_id']
    }
  end

  def oauth_params
    super.merge(team: params[:team])
  end

  def oauth_host
    "https://slack.com/oauth/authorize"
  end
end
