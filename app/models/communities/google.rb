class Communities::Google < Communities::Base
  include Communities::NotifyThirdParty
  set_community_type :google
  set_custom_fields :google_calendar_name
end
