class Identities::Slack < Identities::Base
  set_identity_type :slack
  set_custom_fields :slack_team_id

  def fetch_user_id
    self.uid ||= client.fetch_user_id
  end

  def fetch_team_info
    response = Hash(client.fetch_team_info)
    self.slack_team_id = response.dig('id')
    self.name          = response.dig('name')
    self.logo          = response.dig('icon', 'image_68')
  end

  def channels
    client.get("channels.list") { |response| response['channels'] }
  end
end
