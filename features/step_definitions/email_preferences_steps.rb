When /^I visit the email preferences page$/ do
  visit email_preferences_path
end

When /^I uncheck "(.*?)"$/ do |arg1|
  uncheck arg1
end

Then /^I should be subscribed to proposal closure notification emails$/ do
  @user.reload
  @user.email_preference.subscribed_to_proposal_closure_notifications.should be_true
end

Then /^I should not be subscribed to proposal closure notification emails$/ do
  @user.reload
  @user.email_preference.subscribed_to_proposal_closure_notifications.should be_false
end

Given /^I am subscribed to mention email notifications$/ do
  @user.email_preference.update_attribute(:subscribed_to_mention_notifications, true)
end

Given /^I am not subscribed to mention email notifications$/ do
  @user.email_preference.update_attribute(:subscribed_to_mention_notifications, false)
end

Then /^I should be subscribed to mention notifications$/ do
  @user.reload
  @user.email_preference.subscribed_to_mention_notifications.should be_true
end

Then /^I should not be subscribed to mention notifications$/ do
  @user.reload
  @user.email_preference.subscribed_to_mention_notifications.should be_false
end

Then /^I should not be subscribed to group notifications about "(.*?)"$/ do |arg1|
  @user.email_notifications_for_group?(Group.find_by_name(arg1)).should be_false
end

Then /^I should be subscribed to group notifications about "(.*?)"$/ do |arg1|
  @user.email_notifications_for_group?(Group.find_by_name(arg1)).should be_true
end

Given /^I am subscribed to group notifications about "(.*?)"$/ do |arg1|
  group_id = Group.find_by_name(arg1).id
  membership = @user.memberships.where(group_id: group_id).first
  membership.update_attribute(:subscribed_to_notification_emails, true)
end

Given(/^I am testing all activity summary email beta feature$/) do
  visit beta_features_path
  check 'activity_summary_email'
  click_on 'Update beta features'
end

When /^I click on Monday$/ do
  check 'email_preference_days_to_send_monday'
end

When /^I click on Wednesday$/ do
  check 'email_preference_days_to_send_wednesday'
end

When(/^I unselect the days to receive the summary email$/) do
  uncheck 'email_preference_days_to_send_monday'
  uncheck 'email_preference_days_to_send_wednesday'
end

Then(/^I should be subscribed to the activity summary email$/) do
  @user.email_preference.subscribed_to_activity_summary_email?.should be_true
end

Then(/^I should not be subscribed to the activity summary email$/) do
  @user.email_preference.subscribed_to_activity_summary_email?.should be_false
end

Given(/^I am subscribed to the activity summary email$/) do
  @user.email_preference.update_attribute(:next_activity_summary_sent_at, 2.days.from_now)
end

When(/^I select the time of day$/) do
  select '10', from: :email_preference_hour_to_send
end
