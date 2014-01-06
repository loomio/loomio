Given(/^I am a member of a group with a discussion$/) do
  step 'I am a member of a group'
  step 'the group has a discussion'
end

Given(/^the discussion has a new comment I have not read$/) do
  step 'the discussion has a comment'
end

When(/^I am sent an activity summary email$/) do
  visit "/users/#{@user.id}/activity_summary"
end

Then(/^I should see the group name in the email$/) do
  @last_email = ActionMailer::Base.deliveries.last
  @last_email.should have_content(@group.full_name)
end

Then(/^I should not see the group name in the email$/) do
  @last_email = ActionMailer::Base.deliveries.last
  @last_email.should_not have_content(@group.full_name)
end

Then(/^I should see the discussion title in the email$/) do
  @last_email = ActionMailer::Base.deliveries.last
  @last_email.should have_content(@discussion.title)
end

Given(/^the discussion has a new motion I have not read$/) do
  @motion = FactoryGirl.create :motion, discussion: @discussion, description: "On and on and on and on and on and on and on and on  and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on to the breaky break of dawn"
end

Then(/^I should see the motion name in the email$/) do
  @last_email = ActionMailer::Base.deliveries.last
  @last_email.should have_content(@motion.name)
end

Given(/^the discussion has a motion$/) do
  step 'the discussion has a new motion I have not read'
  visit motion_path(@motion)
end

Given(/^the motion has a new position statement by another user I have not read$/) do
  another_user = FactoryGirl.create :user
  @vote = FactoryGirl.create :vote, :statement => "I like it!", :motion => @motion, :user => another_user
end

Then(/^I should see the position statement in the email$/) do
  @last_email = ActionMailer::Base.deliveries.last
  @last_email.should have_content(@vote.statement)
end

Given(/^the discussion has been read$/) do
  visit discussion_path(@discussion)
end

Then(/^I should not see the discussion title in the email$/) do
  @last_email = ActionMailer::Base.deliveries.last
  @last_email.should_not have_content(@discussion.title)
end

Then(/^I should not see the motion name in the email$/) do
  @last_email = ActionMailer::Base.deliveries.last
  @last_email.should_not have_content(@motion.name)
end

Given(/^there is a new discussion in the group with a long description$/) do
  @discussion = FactoryGirl.create :discussion, group: @group, description: "On and on and on and on and on and on and on and on  and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on to the breaky break of dawn"
end

Given(/^the discussion has a comment I have read$/) do
  step 'the discussion has a comment'
  visit discussion_path(@discussion)
end

Then(/^I should not see the comment in the email$/) do
  @last_email = ActionMailer::Base.deliveries.last
  @last_email.should_not have_content(@comment.body)
end

Given(/^the motion has a position statement by another user I have read$/) do
  step 'the motion has a new position statement by another user I have not read'
  visit motion_path(@motion)
end

Then(/^I should not see the position in the email$/) do
  @last_email = ActionMailer::Base.deliveries.last
  @last_email.should_not have_content(@vote.statement)
end

Then(/^I should not see the description truncated in the email$/) do
  @last_email = ActionMailer::Base.deliveries.last
  @last_email.should_not have_content("...")
end

Then(/^I should see the description truncated in the email$/) do
  @last_email = ActionMailer::Base.deliveries.last
  @last_email.should have_content("...")
end
