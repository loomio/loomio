Given /^I visit the profile page$/ do
  visit profile_path
end

Then /^I should see my display name has been updated$/ do
  expect(page).to have_content @display_name
end

Given /^I fill in and submit the new name$/ do
  @display_name = Faker::Name.name
  fill_in 'user_name', with: @display_name
  click_on 'profile-submit'
end

Then /^I upload a profile image$/ do
  pending "TODO: write test for image upload"
end

Given(/^I change my email to "(.*?)" and submit the form$/) do |email|
  fill_in 'user_email', with: email
  click_on 'profile-submit'
end

When(/^I log out$/) do
  find('#user').click()
  click_on('Sign out')
end

When(/^I log in with "(.*?)"$/) do |email|
  fill_in 'user_email', with: email
  fill_in 'user_password', with: @user.password
  click_on 'sign-in-btn'
end

Then(/^I should see the logged in homepage$/) do
  expect(page).to have_css 'body.dashboard.show'
end

When(/^I update my username$/) do
  @username = Faker::Internet.user_name nil, []
  fill_in 'user_username', with: @username
  click_on 'profile-submit'
end

When(/^I view my user profile$/) do
  visit user_path(@user)
end

Then(/^I should see my username has been updated$/) do
  expect(page).to have_content @username
end

When(/^I edit my username to contain whitespace$/) do
  fill_in 'user_username', with: "user name"
end

When(/^And I submit the form$/) do
  click_on 'profile-submit'
end

Then(/^I should see an error message on the form$/) do
  expect(page).to have_content(I18n.t(:"error.username_must_be_alphanumeric"))
end

Then(/^my username should not be updated$/) do
  expect(@user.username).not_to eq "user name"
end
