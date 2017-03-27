class Communities::Slack < Communities::Base
  include Communities::NotifyThirdParty
  set_custom_fields :slack_channel_name
  set_community_type :slack

  def includes?(participant)
    participant.identities.any? { |i| i.is_member_of?(self) }
  end
end
