Given /^I am logged in as "(.*?)"$/ do |email|
  login(email, 'complex_password')
end

When /^I login as "(.*?)"$/ do |email|
  login(email, 'complex_password')
end

Then /^I should be logged in$/ do
  page.should have_css "body.dashboard.show"
end

Then /^I should not be logged in$/ do
  page.should have_content "Invalid"
end

When /^I login as "(.*?)" with an incorrect password$/ do |email|
  login(email, 'wrong_password')
end

When /^I click on the login button$/ do
  first('.login').click
end

When(/^I log in$/) do
  fill_in 'user_email', with: @user.email
  fill_in 'user_password', :with => 'complex_password'
  click_on 'sign-in-btn'
end

Then(/^I should see the group page$/) do
  page.should have_css('body.groups.show')
end
