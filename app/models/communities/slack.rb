class Communities::Slack < Communities::Base
  include Communities::Notify::ThirdParty
  set_custom_fields :slack_channel_name
  set_community_type :slack

  def channel
    identifier
  end

  def includes?(participant)
    participant.identities.any? { |i| i.is_member_of?(self) }
  end
end
