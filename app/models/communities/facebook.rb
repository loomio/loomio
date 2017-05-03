class Communities::Facebook < Communities::Base
  include Communities::NotifyThirdParty
  set_community_type :facebook
  set_custom_fields :facebook_group_name

  def includes?(participant)
    participant.identities.any? { |i| i.is_member_of?(self) }
  end
end
