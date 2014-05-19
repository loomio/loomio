# Support for Rspec / Capybara subdomain integration testing
# Make sure this file is required by spec_helper.rb
# (e.g. save as spec/support/subdomains.rb)
#
def switch_to_subdomain(subdomain)
  # lvh.me always resolves to 127.0.0.1
  hostname = subdomain ? "#{subdomain}.lvh.me" : "lvh.me"
  Capybara.app_host = "http://#{hostname}"
end
 
def switch_to_main_domain
  switch_to_subdomain nil
end
 
RSpec.configure do |config|
  switch_to_main_domain
end
 
Capybara.configure do |config|
  config.always_include_port = true
end
