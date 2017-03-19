class Identities::Slack < Identities::Base
  set_identity_type :slack
  set_custom_fields :slack_team_id

  def channels
    client.get("channels.list") { |response| response['channels'] }
  end
end
