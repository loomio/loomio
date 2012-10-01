Given /^"(.*?)" is a user$/ do |email|
  FactoryGirl.create :user, :email => email
end

Given /^I am an existing Loomio user$/ do
  @user = FactoryGirl.create :user
end

Given /^I am logged in$/ do
  login @user.email, "password"
end

