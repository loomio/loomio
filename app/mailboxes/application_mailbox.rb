class ApplicationMailbox < ActionMailbox::Base
  routing :all => :inbound_email
end
