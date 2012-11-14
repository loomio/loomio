Given /^there is a user "(.*?)"$/ do |arg1|
  FactoryGirl.create :user, name: arg1, 
                            email: "#{arg1}@example.org",
                            password: 'password'
end

Given /^"(.*?)" is subscribed to daily activity emails$/ do |arg1|
  User.find_by_name('Ben').update_attribute(:subscribed_to_daily_activity_email, true)
end
Given /^there is a group "(.*?)"$/ do |arg1|
  FactoryGirl.create :group, name: arg1
end

Given /^"(.*?)" belongs to "(.*?)"$/ do |arg1, arg2|
  @user = User.find_by_name arg1
  @group = Group.find_by_name arg2
  @group.add_member! @user
end

Given /^there is a discussion "(.*?)" in "(.*?)"$/ do |arg1, arg2|
  @discussion = FactoryGirl.create :discussion, 
                  {title: arg1, group: Group.find_by_name(arg2)}
end

Given /^there is a proposal "(.*?)" from the discussion "(.*?)"$/ do |arg1, arg2|
  @proposal = FactoryGirl.create :motion,
                                 {name: arg1,
                                  discussion: Discussion.find_by_title(arg2)}
end

When /^we send the daily activity email$/ do
  since_time = Date.yesterday
  User.daily_activity_email_recipients.each do |user|
    recent_activity = CollectsRecentActivityByGroup.for(user, since: since_time)
    UserMailer.daily_activity(user, recent_activity, since_time).deliver!
  end
end

Then /^"(.*?)" should get emailed$/ do |arg1|
  last_email = ActionMailer::Base.deliveries.last
  user = User.find_by_name(arg1)
  last_email.to.should include user.email
end

Then /^that email should have the discussion "(.*?)"$/ do |arg1|
  last_email = ActionMailer::Base.deliveries.last
  last_email.body.should have_content arg1
end

Then /^that email should have the proposal "(.*?)"$/ do |arg1|
  last_email = ActionMailer::Base.deliveries.last
  last_email.body.should have_content arg1
end
