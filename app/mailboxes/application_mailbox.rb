class ApplicationMailbox < ActionMailbox::Base
  routing :all => :received_email
end
