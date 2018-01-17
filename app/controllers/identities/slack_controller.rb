class Identities::SlackController < Identities::BaseController
  before_action :respond_with_ok, only: [:participate, :initiate]

  rescue_from(ActionController::ParameterMissing) { head :bad_request }

  def install
    if current_user.identities.find_by(identity_type: :slack) || pending_identity
      index
    else
      params[:back_to] = slack_install_url
      oauth
    end
  end

  def initiate
    if params['token'] == ENV['SLACK_VERIFICATION_TOKEN']
      render plain: ::Slack::Initiator.new(params).initiate
    else
      head :bad_request
    end
  end

  def participate
    payload = JSON.parse(params.require(:payload))
    if payload['token'] == ENV['SLACK_VERIFICATION_TOKEN']
      render json: ::Slack::Participator.new(JSON.parse(params.require(:payload))).participate
    else
      head :bad_request
    end
  end

  def authorized
    @team = params[:team]
    render template: 'slack/authorized', layout: 'application'
  end

  private

  def respond_with_ok
    head :ok if params[:ssl_check].present?
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
