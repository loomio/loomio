require "omnicontacts"

Rails.application.middleware.use OmniContacts::Builder do
  importer :gmail, Rails.application.secrets.omni_contacts_google_key, Rails.application.secrets.omni_contacts_google_secret, max_results: 2000
  #importer :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], max_results: 1000
  #importer :yahoo, ENV['YAHOO_KEY'], ENV['YAHOO_SECRET']
  #importer :hotmail, "client_id", "client_secret"
end

