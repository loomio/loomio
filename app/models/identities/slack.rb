class Identities::Slack < Identities::Base
  set_identity_type :slack
  set_custom_fields :slack_team_id

  def fetch_channels
    client.get("channels.list") { |response| response }
  end
end
