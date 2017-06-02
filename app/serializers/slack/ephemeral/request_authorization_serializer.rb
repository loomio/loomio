class Slack::Ephemeral::RequestAuthorizationSerializer < Slack::BaseSerializer
  include Slack::Ephemeral::Message

  def text
    I18n.t(:"slack.request_authorization_message", url: request_authorization_url)
  end

  private

  def request_authorization_url
    slack_oauth_url(default_url_options.merge(back_to: success_url, team: object['id']))
  end

  def success_url
    slack_authorized_url(default_url_options.merge(team: object['domain']))
  end
end
