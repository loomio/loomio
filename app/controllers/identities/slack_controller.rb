class Identities::SlackController < Identities::BaseController
  before_filter :respond_with_ok, only: [:participate, :initiate]

  def install
    if current_user.slack_identity || pending_identity
      boot_angular_ui
    else
      params[:back_to] = slack_install_url
      oauth
    end
  end

  def participate
    render json: respond_with_stance ||
                 respond_with_invitation ||
                 respond_with_unauthorized
  end

  def initiate
    attempt = ::Slack::Initiator.new(initiate_params).initiate!
    case attempt[:error]
    when nil           then respond_with_url(attempt[:url])
    when :bad_identity then respond_with_unauthorized(params[:team_domain])
    when :bad_type     then respond_with_help
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

  def respond_with_url(url)
    render text: I18n.t(:"slack.initiate", type: initiate_params[:type], url: url)
  end

  def respond_with_stance
    event = ::Slack::Participator.new(participate_params).participate!
    ::Slack::StanceCreatedSerializer.new(event, root: false).as_json
  end

  def respond_with_invitation
    poll = Poll.find(participate_params[:poll_id])
    return unless poll.group&.identity_type == 'slack'
    ::Slack::GroupInvitationSerializer.new(poll, root: false).as_json
  end

  def respond_with_unauthorized
    ::Slack::RequestAuthorizationSerializer.new(payload, root: false).as_json
  end

  def respond_with_help
    render text: I18n.t(:"slack.slash_command_help", type: initiate_params[:type])
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

  def participate_params
    @participate_params ||= {
      uid:     payload.dig('user', 'id'),
      poll_id: payload.dig('callback_id'),
      choice:  payload.dig('actions', 0, 'name')
    }
  end

  def initiate_params
    {
      user_id:      params[:user_id],
      team_id:      params[:team_id],
      channel_id:   params[:channel_id],
      channel_name: params[:channel_name],
      type:         /^\S*/.match(params[:text]).to_s.strip, # use first word as poll type
      title:        /\s.*$/.match(params[:text]).to_s.strip # use remaining words as poll title
    }
  end

  def payload
    @payload ||= JSON.parse(params.require(:payload))
  end

  def oauth_host
    "https://slack.com/oauth/authorize"
  end
end
