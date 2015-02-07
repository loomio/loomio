Given(/^I am on the user registration page$/) do
  visit new_user_registration_path
end

Given(/^I fill in all the fields including the honeypot$/) do
  fill_in 'user_name', with: 'some Bot'
  fill_in 'user_email', with: 'some.Bot@bots_r_us.com'
  fill_in 'user_password', with: 'complex_password'
  fill_in 'user_password_confirmation', with: 'complex_password'
  fill_in 'user_honeypot', with: 'something?'
end

Then(/^I should be redirected back to the registration page$/) do
  page.should have_css('body.registrations.new')
end

Then(/^I should see a message telling me not to fill in the honeypot field$/) do
  page.should have_content I18n.t(:honeypot_warning)
end
