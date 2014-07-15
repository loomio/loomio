require "omnicontacts"

Rails.application.middleware.use OmniContacts::Builder do
  importer :gmail, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET']
  importer :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']
  #importer :yahoo, "consumer_id", "consumer_secret", {:callback_path => '/callback'}
  #importer :hotmail, "client_id", "client_secret"
end

