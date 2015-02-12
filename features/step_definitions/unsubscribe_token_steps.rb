Given /^I have a user account but not I'm logged in$/ do
  @user = FactoryGirl.create :user, name: 'User Guy',
                                    email: "user@example.org",
                                    password: 'complex_password'

end

Given /^I am subscribed to missed yesterday email$/ do
  @user.update_attribute(:email_missed_yesterday, true)
end

When /^I visit email_preferences with unsubscribe_token in the params$/ do
  visit email_preferences_path(unsubscribe_token: @user.unsubscribe_token)
end

Then /^I should be able to update my email preferences$/ do
  uncheck 'user[email_followed_threads]'
  click_on 'Save preferences'
  page.should have_content 'Your email settings have been updated.'
  @user.reload.email_followed_threads.should be false
end
