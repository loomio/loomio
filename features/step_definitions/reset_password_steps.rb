Given(/^I have a loomio account$/) do
  @user = FactoryGirl.create(:user)
end

When(/^I reset my password$/) do
  visit new_user_password_path
  fill_in 'Email', with: @user.email
  click_on 'Send me reset password instructions'
end

Then(/^my password should be reset and I should be logged in$/) do
  open_email(@user.email)
  click_email_link_matching(/reset/)
  fill_in 'New password', with: 'hellothere'
  fill_in 'Confirm new password', with: 'hellothere'
  click_on 'Change my password'
  page.should have_content 'Your password has been changed successfully. You are now signed in.'
end

When(/^I click the change password link$/) do
  click_on 'change-password'
end

When(/^I change my password and submit the form$/) do
  fill_in 'New password', with: 'newpassword'
  fill_in 'Confirm new password', with: 'newpassword'
  click_on 'Change my password'
end

Then(/^I should be notified that my password has been changed$/) do
  page.should have_content 'Your password was changed successfully'
end

When(/^I log in using my new password$/) do
  fill_in 'user_email', with: @user.email
  fill_in 'user_password', with: 'newpassword'
  click_on 'sign-in-btn'
end

Then(/^I should see the dashboard$/) do
  page.should have_css('body.dashboard.show')
end
