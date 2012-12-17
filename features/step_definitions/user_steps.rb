Given /^"(.*?)" is a user$/ do |email|
  FactoryGirl.create :user, :email => email
end

Given /^"(.*?)" is an existing user$/ do |arg1|
  user = FactoryGirl.create :user, name: arg1,
                            email: "#{arg1}@example.org"
end

Given /^I am an existing Loomio user$/ do
  @user = FactoryGirl.create :user
end

Given /^I am logged in$/ do
  @user ||= FactoryGirl.create :user
  login @user.email, "password"
end

