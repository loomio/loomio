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
    @team, @channel = params[:slack].to_s.split("-")
    if user_to_join
      FormalGroup.by_slack_channel(@channel).each { |g| g.add_member! user_to_join }
      sign_in user_to_join
    end
    render template: 'slack/authorized', layout: 'basic'
  end

  private

  def respond_with_ok
    head :ok if params[:ssl_check].present?
  end

  def complete_identity(identity)
    super
    identity.fetch_team_info
  end

  def user_to_join
    @user_to_join ||= current_user.presence || identity_to_join&.user || identity_to_join&.find_or_create_user!
  end

  def identity_to_join
    @identity_to_join ||= Identities::Slack.find_by(id: session.delete(:pending_identity_id))
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
