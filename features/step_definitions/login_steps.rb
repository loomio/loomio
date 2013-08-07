Given /^I am logged in as "(.*?)"$/ do |email|
  login(email, 'password')
end

When /^I login as "(.*?)"$/ do |email|
  login(email, 'password')
end

Then /^I should be logged in$/ do
  page.should have_css "body.dashboard.show"
end

Then /^I should not be logged in$/ do
  page.should have_content "Invalid email or password"
end

When /^I login as "(.*?)" with an incorrect password$/ do |email|
  login(email, 'wrong_password')
end

When(/^I log in$/) do
  fill_in 'user_email', with: @user.email
  fill_in 'user_password', :with => 'password'
  click_on 'sign-in-btn'
end

Then(/^I should see the group page$/) do
  page.should have_css('body.groups.show')
end
