module Identities::Slack::Initiate
  def initiate
    render text: respond_with_url ||
                 respond_with_help ||
                 respond_with_unauthorized(id: params[:team_id], domain: params[:team_domain])
  end

  private

  def respond_with_url
    return unless attempt[:error] == :bad_identity
    I18n.t(:"slack.initiate", type: initiate_params[:type], url: attempt[:url])
  end

  def respond_with_help
    return unless attempt[:error] == :bad_type
    I18n.t(:"slack.slash_command_help", type: initiate_params[:type])
  end

  def initiate_attempt
    @initiate_attempt ||= ::Slack::Initiator.new(initiate_params).initiate!
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
end
