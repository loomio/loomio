Given /^I am logged in as "(.*?)"$/ do |arg1|
  login(arg1,'password')
end

When /^enter my login details$/ do
  visit "/"
  page.should have_content "sign in"
  fill_in 'user_email', with: "furry@example.com"
  fill_in 'user_password', with: "password"
  click_on "Sign in"
end

Then /^I should be logged in$/ do
  page.should have_content "This page is the Dashboard"
end

Given /^I am not a registered User$/ do
  User.where(:email=>"fake@email.com").size == 0
end

When /^I enter my incorrect login details$/ do
  visit "/"
  page.should have_content "sign in"
  fill_in 'user_email', with: "fake@email.com"
  fill_in 'user_password', with: "password"
  click_on "Sign in"
end


Then /^I should not be logged in$/ do
  page.should have_content "Invalid email or password"
end

When /^I enter my email incorrectly$/ do
  visit "/"
  page.should have_content "sign in"
  fill_in 'user_email', with: "furry@oops_a_mistake.com"
  fill_in 'user_password', with: "password"
  click_on "Sign in"
end

When /^I enter my password incorrectly$/ do
  visit "/"
  page.should have_content "sign in"
  fill_in 'user_email', with: "furry@example.com"
  fill_in 'user_password', with: "wrong_password"
  click_on "Sign in"
end
