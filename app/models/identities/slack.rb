class Identities::Slack < Identities::Base
  include Identities::WithClient
  set_identity_type :slack
  set_custom_fields :slack_team_id, :slack_team_name, :slack_team_logo

  def fetch_user_info
    apply_user_info(client.fetch_user_info.json)
  end

  def apply_user_info(payload)
    self.name  ||= payload['real_name_normalized']
    self.email ||= payload['email']
    self.logo  ||= payload['image_72']
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
