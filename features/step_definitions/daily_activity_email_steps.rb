Given /^there is a user "(.*?)"$/ do |arg1|
  @user_email = "#{arg1}@example.org"
  FactoryGirl.create :user, name: arg1,
                            email: @user_email,
                            password: 'complex_password'
end

Given /^"(.*?)" is subscribed to daily activity emails$/ do |arg1|
  User.find_by_name(arg1).update_attribute(:subscribed_to_daily_activity_email, true)
end

Given /^there is a group "(.*?)"$/ do |arg1|
  FactoryGirl.create :formal_group, name: arg1
end

Given /^"(.*?)" belongs to "(.*?)"$/ do |arg1, arg2|
  @user = User.find_by_name arg1
  @group = Group.find_by_name arg2
  @group.add_member! @user
end

Given /^there is a discussion "(.*?)" in "(.*?)"$/ do |arg1, arg2|
  @discussion = create_discussion title: arg1, group: Group.find_by_name(arg2)
end

Given /^there is a proposal "(.*?)" from the discussion "(.*?)"$/ do |arg1, arg2|
  @proposal = FactoryGirl.create :motion,
                                 {name: arg1,
                                  discussion: Discussion.find_by_title(arg2)}
end

When /^we send the daily activity email$/ do
  SendActivitySummary.to_subscribers!
end

Then /^"(.*?)" should get the daily activity email$/ do |arg1|
  user = User.find_by_name(arg1)
  found_email = false
  ActionMailer::Base.deliveries.each do |delivery|
    if (delivery.to.last.include?(user.email) && delivery.subject.include?("Loomio - Summary of the last 24 hours"))
      found_email = true
    end
  end
  found_email.should be true
end

Then /^"(.*?)" should not get the daily activity email$/ do |arg1|
  user = User.find_by_name(arg1)
  found_email = false
  ActionMailer::Base.deliveries.each do |delivery|
    if (delivery.to.last.include?(user.email) && delivery.subject.include?("Loomio - Summary of the last 24 hours"))
      found_email = true
    end
  end
  found_email.should be false
end

Then /^that email should have the discussion "(.*?)"$/ do |arg1|
  last_email = ActionMailer::Base.deliveries.last
  last_email.default_part_body.should have_content arg1
end

Then /^that email should have the proposal "(.*?)"$/ do |arg1|
  last_email = ActionMailer::Base.deliveries.last
  last_email.default_part_body.should have_content arg1
end

Then /^that email should have an unsubscribe link$/ do |arg1|
  current_email.should have_content 'Unsubscribe or change your email preferences'
end
