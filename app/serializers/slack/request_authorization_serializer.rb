class Slack::RequestAuthorizationSerializer < Slack::BaseSerializer
  include Slack::EphemeralMessage

  def text
    I18n.t(:"slack.request_authorization_message", url: request_authorization_url)
  end

  private

  def team
    Hash(object['team'])
  end

  def request_authorization_url
    slack_oauth_url(default_url_options.merge(back_to: success_url, team: team['id']))
  end

  def success_url
    slack_authorized_url(default_url_options.merge(team: team['domain']))
  end
end
