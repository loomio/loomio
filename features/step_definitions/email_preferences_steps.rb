When /^I visit the email preferences page$/ do
  visit email_preferences_path
end

Then /^I should be subscribed to the daily actitivy email$/ do
  @user.reload
  @user.subscribed_to_daily_activity_email.should be true
end

Given /^I am subscribed to the daily activity email$/ do
  @user.update_attribute(:subscribed_to_daily_activity_email , true)
end

When /^I uncheck "(.*?)"$/ do |arg1|
  uncheck arg1
end

Then /^I should not be subscribed to the daily actitivy email$/ do
  @user.reload
  @user.subscribed_to_daily_activity_email.should be false
end

Then /^I should be subscribed to proposal closure notification emails$/ do
  @user.reload
  @user.subscribed_to_proposal_closure_notifications.should be true
end

Then /^I should not be subscribed to proposal closure notification emails$/ do
  @user.reload
  @user.subscribed_to_proposal_closure_notifications.should be false
end

Given /^I am subscribed to mention email notifications$/ do
  @user.update_attribute(:subscribed_to_mention_notifications, true)
end

Given /^I am not subscribed to mention email notifications$/ do
  @user.update_attribute(:subscribed_to_mention_notifications, false)
end

Then /^I should be subscribed to mention notifications$/ do
  @user.reload
  @user.subscribed_to_mention_notifications.should be true
end

Then /^I should not be subscribed to mention notifications$/ do
  @user.reload
  @user.subscribed_to_mention_notifications.should be false
end

Then /^I should not be subscribed to group notifications about "(.*?)"$/ do |arg1|
  @user.email_notifications_for_group?(Group.find_by_name(arg1)).should be false
end

Then /^I should be subscribed to group notifications about "(.*?)"$/ do |arg1|
  @user.email_notifications_for_group?(Group.find_by_name(arg1)).should be true
end

Given /^I am subscribed to group notifications about "(.*?)"$/ do |arg1|
  group_id = Group.find_by_name(arg1).id
  membership = @user.memberships.where(group_id: group_id).first
  membership.update_attribute(:subscribed_to_notification_emails, true)
end
