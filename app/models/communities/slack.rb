class Communities::Slack < Communities::Base
  include Communities::Notify::ThirdParty
  set_custom_fields :slack_channel_name
  set_community_type :slack

  def channel
    identifier
  end
end
