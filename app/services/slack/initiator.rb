class ::Slack::Initiator
  include Routing

  def initialize(params)
    @channel_id  = params[:channel]
    @team_id     = params[:team_id]
    @team_domain = params[:team_domain]
    @poll_type   = /^\S*/.match(params[:text]).to_s.strip # use first word as poll type
    @poll_title  = /\s.*$/.match(params[:text]).to_s.strip # use remaining words as poll title
  end

  def initiate
    return command_help      unless AppConfig.poll_templates.keys.include?(@poll_type)
    return team_unauthorized unless target_groups.any?
    return channel_unknown   unless target_group.present?

    generate_poll_url
  end

  private

  def command_help
    I18n.t(:"slack.slash_command_help")
  end

  def channel_unknown
    I18n.t(:"slack.unknown_channel", integrations: target_groups.map do |group|
      "#{group.full_name} - #{group.group_identities.first.slack_channel_name}"
    end.join("\n"))
  end

  def team_unauthorized
    I18n.t(:"slack.request_authorization_message", url: slack_oauth_url(
      back_to: slack_authorized_url(team: @team_domain),
      team: @team_id
    ))
  end

  def generate_poll_url
    I18n.t(:"slack.initiate", type: @poll_type, url: new_poll_url(
      type:     @poll_type,
      title:    @poll_title,
      group_id: target_group.id
    ))
  end

  def target_group
    @target_group ||= target_groups.by_slack_channel(@channel_id).first
  end

  def target_groups
    @target_groups ||= FormalGroup.by_slack_team(@team_id)
  end
end
