class Identities::Slack < Identities::Base
  include Identities::WithClient
  set_identity_type :slack
  set_custom_fields :slack_team_id, :slack_team_name, :slack_team_logo

  def fetch_user_info
    response   = Hash(client.fetch_user_info(self.uid))
    self.name  = response['real_name']
    self.email = response.dig('profile', 'email')
    self.logo  = response.dig('profile', 'image_48')
  end

  def fetch_team_info
    response             = Hash(client.fetch_team_info)
    self.slack_team_id   = response['id']
    self.slack_team_name = response['name']
    self.slack_team_logo = response.dig('icon', 'image_68')
  end

  def channels
    client.get("channels.list") { |response| response['channels'] }
  end
end
