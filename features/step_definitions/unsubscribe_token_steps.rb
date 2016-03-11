Given /^I have a user account but not I'm logged in$/ do
  @user = FactoryGirl.create :user, name: 'User Guy',
                                    email: "user@example.org",
                                    password: 'complex_password'
  @group = FactoryGirl.create :group
  @group.add_member!(@user)

end

Given /^I am subscribed to missed yesterday email$/ do
  @user.update_attribute(:email_missed_yesterday, true)
end

When /^I visit email_preferences with unsubscribe_token in the params$/ do
  visit email_preferences_path(unsubscribe_token: @user.unsubscribe_token)
end

When /^I visit email_preferences$/ do
  visit email_preferences_path
end

Then /^I should see the sign\-in page$/ do
  page.should have_css('body.pages.sessions.new')
end

Then /^I should be able to update my email preferences$/ do
  uncheck 'user[email_missed_yesterday]'
  click_on 'Update settings'
  page.should have_content 'Your email settings have been updated.'
  @user.reload.email_missed_yesterday.should be false
end

When(/^change the group volume to quiet/) do
  expect(@group.membership_for(@user).volume_is_normal?).to be true
  choose 'set_group_volume_quiet'
  click_on 'Update settings'
end

Then(/^all my groups should be quiet/) do
  expect(@group.membership_for(@user).volume_is_quiet?).to be true
end
