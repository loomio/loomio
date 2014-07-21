require "omnicontacts"

Rails.application.middleware.use OmniContacts::Builder do
  importer :gmail, ENV['OMNI_CONTACTS_GOOGLE_KEY'], ENV['OMNI_CONTACTS_GOOGLE_SECRET'], max_results: 1000
  importer :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], max_results: 1000
  importer :yahoo, ENV['YAHOO_KEY'], ENV['YAHOO_SECRET']
  #importer :hotmail, "client_id", "client_secret"
end

