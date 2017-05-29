module Identities::Slack::Initiate
  def initiate
    attempt = ::Slack::Initiator.new(initiate_params).initiate!
    case attempt[:error]
    when nil           then respond_with_url(attempt[:url])
    when :bad_identity then respond_with_unauthorized(id: params[:team_id], domain: params[:team_domain])
    when :bad_type     then respond_with_help
    end
  end

  private

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

  def respond_with_url(url)
    render text: I18n.t(:"slack.initiate", type: initiate_params[:type], url: url)
  end

  def respond_with_help
    render text: I18n.t(:"slack.slash_command_help", type: initiate_params[:type])
  end
end
