module Identities::Slack::Initiate
  def initiate
    render text: respond_with_url                   ||
                 respond_with_initiate_unauthorized ||
                 respond_with_help
  end

  private

  def respond_with_url
    return unless AppConfig.poll_templates.keys.include?(initiate_type) && initiate_group.present?
    I18n.t(:"slack.initiate", type: initiate_type, url: new_poll_url(
      type: initiate_type,
      title: initiate_title,
      group_id: initiate_group.id
    ))
  end

  def respond_with_initiate_unauthorized
    return if initiate_group.present?
    I18n.t(:"slack.request_authorization_message", url: request_authorization_url(
      'id' =>     params[:team_id],
      'domain' => params[:team_domain]
    ))
  end

  def respond_with_help
    I18n.t(:"slack.slash_command_help")
  end

  def initiate_ensure_token
    head :bad_request unless params[:token] == ENV['SLACK_VERIFICATION_TOKEN']
  end

  def initiate_identity
    @initiate_identity ||= Identities::Slack.find_by(identity_type: :slack, uid: params[:user_id])
  end

  def initiate_group
    @initiate_group ||= FormalGroup
      .joins(:identities)
      .where("(omniauth_identities.custom_fields->'slack_team_id')::jsonb ? :team_id",    team_id:    params[:team_id])
      .where("(group_identities.custom_fields->'slack_channel_id')::jsonb ? :channel_id", channel_id: params[:channel_id])
      .first
  end

  def initiate_type
    @initiate_type    ||= /^\S*/.match(params[:text]).to_s.strip # use first word as poll type
  end

  def initiate_title
    @initiate_title   ||= /\s.*$/.match(params[:text]).to_s.strip # use remaining words as poll title
  end
end
