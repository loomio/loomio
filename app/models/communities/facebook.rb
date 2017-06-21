class Communities::Facebook < Communities::Base
  include Communities::Notify::ThirdParty
  set_community_type :facebook
  set_custom_fields :facebook_group_name
end
