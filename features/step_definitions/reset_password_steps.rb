Given(/^I have a loomio account$/) do
  @user = FactoryGirl.create(:user)
end

When(/^I reset my password$/) do
  visit new_user_password_path
  fill_in 'Email', with: @user.email
  view_screenshot
  click_on 'Send me reset password instructions'
  view_screenshot
end

Then(/^my password should be reset and I should be logged in$/) do
  open_email(@user.email)
  click_email_link_matching(/reset/)
  fill_in 'New password', with: 'hellothere'
  fill_in 'Confirm new password', with: 'hellothere'
  click_on 'Change my password'
  page.should have_content 'Your password was changed successfully. You are now signed in.'
end
