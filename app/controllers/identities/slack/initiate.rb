module Identities::Slack::Initiate
  def initiate
    render text: respond_with_url ||
                 respond_with_help ||
                 respond_with_initiate_unauthorized
  end

  private

  def respond_with_url
    return unless initiate_attempt[:error] == :bad_identity
    I18n.t(:"slack.initiate", type: initiate_params[:type], url: initiate_attempt[:url])
  end

  def respond_with_help
    return unless initiate_attempt[:error] == :bad_type
    I18n.t(:"slack.slash_command_help", type: initiate_params[:type])
  end

  def respond_with_initiate_unauthorized
    I18n.t(:"slack.request_authorization_message", url: request_authorization_url(
      id:   initiate_params[:team_id],
      name: initiate_params[:team_domain]
    ))
  end

  def initiate_attempt
    @initiate_attempt ||= ::Slack::Initiator.new(initiate_params).initiate!
  end

  def initiate_params
    params.slice(:user_id, :team_id, :team_domain, :channel_id, :channel_name).merge(
      type:  /^\S*/.match(params[:text]).to_s.strip,  # use first word as poll type
      title: /\s.*$/.match(params[:text]).to_s.strip  # use remaining words as poll title
    ).symbolize_keys
  end
end
