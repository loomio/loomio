Given(/^I am a member of a group with a discussion$/) do
  step 'I am a member of a group'
  step 'the group has a discussion'
end

Given(/^the discussion has a new comment I have not read$/) do
  step 'the discussion has a comment'
end

Given(/^the discussion has a new motion I have not read$/) do
  @motion = FactoryGirl.create :motion, discussion: @discussion, description: "On and on and on and on and on and on and on and on  and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on to the breaky break of dawn"
end

Given(/^the discussion has a motion$/) do
  step 'the discussion has a new motion I have not read'
end

Given(/^the motion has a new position statement by another user I have not read$/) do
  another_user = FactoryGirl.create :user
  @vote = FactoryGirl.create :vote, :statement => "I like it!", :motion => @motion, :user => another_user
end

Given(/^the discussion has been read$/) do
  visit discussion_path(@discussion)
end

Given(/^there is a new discussion in the group with a long description$/) do
  @discussion = FactoryGirl.create :discussion, group: @group, description: "On and on and on and on and on and on and on and on  and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on to the breaky break of dawn"
end

Given(/^the discussion has a comment I have read$/) do
  step 'the discussion has a comment'
  visit discussion_path(@discussion)
end

Given(/^the motion has a position statement by another user I have read$/) do
  step 'the motion has a new position statement by another user I have not read'
  visit motion_path(@motion)
end

Given(/^the discussion has an old motion with old unread activity I have not read$/) do
  @motion = FactoryGirl.create :motion, discussion: @discussion
  step 'the motion has a new position statement by another user I have not read'
  @motion.last_non_vote_activity_at = 8.day.ago
  @motion.last_vote_at = 8.days.ago
  @motion.save
end

Given(/^the discussion has an old comment I have not read$/) do
  step 'the discussion has a new comment I have not read'
  @discussion.last_comment_at = 8.days.ago
  @discussion.save
end

Given(/^the motion has been read$/) do
  visit motion_path(@motion)
end

Given(/^the discussion has been read in a prvevious summary$/) do
  @discussion.last_non_comment_activity_at = 8.days.ago
  @discussion.save
end

Given(/^the motion has been read in a previous summary$/) do
  @motion.last_non_vote_activity_at = 8.days.ago
  @motion.save
end

Given(/^I log in as another user in the group$/) do
  @another_user = FactoryGirl.create :user, email: 'furry@example.com'
  @group.add_admin! @another_user
  step 'I log out'
  step 'I am logged in as "furry@example.com"'
end

Given(/^the discussion title is updated by another user$/) do
  step 'I log in as another user in the group'
  visit discussion_path(@discussion)
  step 'I choose to edit the discussion title'
  step 'I fill in and submit the discussion title form'
  step 'I log out'
  step 'I am logged in as "#{@user.email}"'
end

Given(/^the discussion description is updated by another user$/) do
  step 'I log in as another user in the group'
  visit discussion_path(@discussion)
  step 'I choose to edit the discussion description'
  step 'I fill in and submit the discussion description form'
  step 'I log out'
  step 'I am logged in as "#{@user.email}"'
end

Given(/^the discussion has a motion with no new activity$/) do
  step 'the discussion has an old motion with old unread activity I have not read'
end

When(/^I am sent an activity summary email$/) do
  UserMailer.activity_summary(@user).deliver
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
  @discussion.reload
  @last_email = ActionMailer::Base.deliveries.last
  @last_email.should have_content(@discussion.title)
end

Then(/^I should see the motion name in the email$/) do
  @last_email = ActionMailer::Base.deliveries.last
  @last_email.should have_content(@motion.name)
end

Then(/^I should see the position statement in the email$/) do
  @last_email = ActionMailer::Base.deliveries.last
  @last_email.should have_content(@vote.statement)
end

Then(/^I should not see the discussion title in the email$/) do
  @last_email = ActionMailer::Base.deliveries.last
  @last_email.should_not have_content(@discussion.title)
end

Then(/^I should not see the motion name in the email$/) do
  @last_email = ActionMailer::Base.deliveries.last
  @last_email.should_not have_content(@motion.name)
end

Then(/^I should not see the comment in the email$/) do
  @last_email = ActionMailer::Base.deliveries.last
  @last_email.should_not have_content(@comment.body)
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