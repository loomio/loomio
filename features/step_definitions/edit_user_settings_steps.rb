Given /^I visit the user settings page$/ do
  visit "/settings"
end

Given /^I fill in and submit the new name$/ do
  @display_name = Faker::Name.name
  fill_in 'user_name', with: @display_name
  click_on 'user-settings-submit'
end

Given(/^I fill in and submit "(.*?)" as the new email$/) do |email|
  fill_in 'user_email', with: email
  click_on 'user-settings-submit'
end

When(/^I log out$/) do
  find('#user').click
  click_on "Sign out"
end

When(/^I sign in with "(.*?)"$/) do |email|
  fill_in :user_email, with: email
  fill_in :user_password, with: @user.password
  find('#sign-in-btn').click()
end

Then /^I should see my display name has been updated$/ do
  page.should have_content(@display_name)
end

Then(/^I should see the my logged in home page$/) do
  page.should have_css('body.dashboard.show')
end

Then /^I upload a profile image$/ do
  pending "TODO: write test for image upload"
end