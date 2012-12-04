Given /^I have a user account but not I'm logged in$/ do
  @user = FactoryGirl.create :user, name: 'User Guy', 
                                    email: "user@example.org",
                                    password: 'password'

end

Given /^I am subscribed to daily activity email$/ do
  @user.update_attribute(:subscribed_to_daily_activity_email, true)
end

When /^I visit email_preferences with unsubscribe_token in the params$/ do
  visit email_preferences_path(unsubscribe_token: @user.unsubscribe_token)
end

Then /^I should be able to update my email preferences$/ do
  uncheck 'user[subscribed_to_daily_activity_email]'
  click_on 'Update preferences'
  page.should have_content 'Your settings have been updated.'
end
