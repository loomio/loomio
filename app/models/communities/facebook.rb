class Communities::Facebook < Communities::Base
  include Communities::NotifyThirdParty
  set_community_type :facebook
  set_custom_fields :facebook_group_name
end
