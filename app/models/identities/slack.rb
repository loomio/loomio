class Identities::Slack < Identities::Base
  include Identities::WithClient
  set_identity_type :slack
  set_custom_fields :slack_team_id, :slack_team_name, :slack_team_logo

  def apply_user_info(payload)
    self.name  ||= payload['real_name']
    self.email ||= payload.dig('profile', 'email')
    self.logo  ||= payload.dig('profile', 'image_48')
  end

  def fetch_team_info
    json                 = client.fetch_team_info.json
    self.slack_team_id   = json['id']
    self.slack_team_name = json['name']
    self.slack_team_logo = json.dig('icon', 'image_68')
  end

  def channels
    client.fetch_channels
  end
end
