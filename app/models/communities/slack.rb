class Communities::Slack < Communities::Base
  include Communities::NotifyThirdParty
  set_custom_fields :slack_channel_name
  set_community_type :slack

  def channel
    identifier
  end
end
