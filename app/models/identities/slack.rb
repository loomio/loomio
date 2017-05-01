class Identities::Slack < Identities::Base
  include Identities::WithClient
  set_identity_type :slack
  set_custom_fields :slack_team_id, :slack_team_name, :slack_team_logo

  def fetch_user_info
    json       = Hash(client.fetch_user_info(self.uid).json)
    self.name  = json['real_name']
    self.email = json.dig('profile', 'email')
    self.logo  = json.dig('profile', 'image_48')
  end

  def fetch_team_info
    json                 = Hash(client.fetch_team_info.json)
    self.slack_team_id   = json['id']
    self.slack_team_name = json['name']
    self.slack_team_logo = json.dig('icon', 'image_68')
  end

  def channels
    client.fetch_channels
  end
end
