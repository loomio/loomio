Given /^"(.*?)" is a user$/ do |email|
  FactoryGirl.create :user, :email => email
end
