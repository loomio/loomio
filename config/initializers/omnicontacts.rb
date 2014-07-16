require "omnicontacts"

Rails.application.middleware.use OmniContacts::Builder do
  importer :gmail, ENV['OMNI_CONTACTS_GOOGLE_KEY'], ENV['OMNI_CONTACTS_GOOGLE_SECRET'], max_results: 1000
  importer :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], max_results: 1000
  #importer :yahoo, "consumer_id", "consumer_secret", {:callback_path => '/callback'}
  #importer :hotmail, "client_id", "client_secret"
end

