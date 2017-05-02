class Communities::Slack < Communities::Base
  include Communities::NotifyThirdParty
  set_community_type :slack
  set_custom_fields :slack_channel_name
end
