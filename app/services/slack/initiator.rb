class ::Slack::Initiator
  include Routing

  def initialize(params)
    @channel_id  = params[:channel_id]
    @team_id     = params[:team_id]
    @team_domain = params[:team_domain]
    # use first word as poll type or 'thread'
    @type        = /^\S*/.match(params[:text]).to_s.strip.to_sym
    # use remaining words as poll / discussion title
    @title       = /\s.*$/.match(params[:text]).to_s.strip
  end

  def initiate
    return command_help      unless is_valid_command?
    return team_unauthorized unless target_groups.any?
    return channel_unknown   unless target_group.present?
    initiate_url
  end

  private

  def is_valid_command?
    (poll_types + [:thread, :discussion]).include?(@type)
  end

  def initiate_url
    I18n.t(:"slack.initiate", type: @type, url: url_target(
      type:     @type,
      title:    @title,
      group_id: target_group.id
    ))
  end

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

  def url_target(params = {})
    if poll_types.include?(@type)
      new_poll_url(params)
    else
      new_discussion_url(params)
    end
  end

  def poll_types
    AppConfig.poll_templates.keys.map(&:to_sym)
  end

  def target_group
    @target_group ||= target_groups.by_slack_channel(@channel_id).first
  end

  def target_groups
    @target_groups ||= Group.by_slack_team(@team_id)
  end
end
