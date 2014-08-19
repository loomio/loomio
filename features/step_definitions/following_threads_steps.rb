When(/^someone else creates a discussion in my group$/) do
  @discussion = FactoryGirl.build(:discussion, group: @group)
  DiscussionService.start_discussion(@discussion)
end

Then(/^I should not be following the discussion$/) do
  @discussion_reader = DiscussionReader.for(discussion: @discussion,
                                            user: @user)
  @discussion_reader.following?.should be false
end

When(/^I create a discussion in my group$/) do
  @discussion = FactoryGirl.build(:discussion, group: @group, author: @user)
  DiscussionService.start_discussion(@discussion)
end

Then(/^I should be following the discussion$/) do
  @discussion.reload
  @discussion_reader = DiscussionReader.for(discussion: @discussion,
                                            user: @user)
  @discussion_reader.following?.should be true
end

Given(/^I am autofollowing new discussions in my group$/) do
  @membership = @user.memberships.find_by(group_id: @group.id)
  @membership.following_by_default = true
  @membership.save!
end

Given(/^there is a discussion I am not following$/) do
  @discussion = FactoryGirl.build(:discussion, group: @group)
  DiscussionService.start_discussion(@discussion)
end

When(/^I comment in the discussion$/) do
  @comment = FactoryGirl.build(:comment, discussion: @discussion, author: @user)
  DiscussionService.add_comment(@comment)
end

When(/^I like a comment in the discussion$/) do
  @comment = FactoryGirl.create(:comment, discussion: @discussion)
  DiscussionService.like_comment(@user, @comment)
end

When(/^I comment on the discussion, mentioning Rich$/) do
  @rich = FactoryGirl.create(:user, username: 'rich')
  @discussion.group.add_member!(@rich)
  @comment = FactoryGirl.build(:comment,
                               discussion: @discussion,
                               author: @user,
                               body: 'hi @rich')
  DiscussionService.add_comment(@comment)
end

Then(/^I should be following it$/) do
  @discussion.reload
  @discussion_reader = DiscussionReader.for(discussion: @discussion,
                                            user: @user)

  @discussion_reader.following?.should be true
end


Then(/^Rich should be following the discussion$/) do
  @discussion_reader = DiscussionReader.for(discussion: @discussion,
                                            user: @rich)

  @discussion_reader.following?.should be true
end

Given(/^I update the title$/) do
  DiscussionService.edit_discussion(@user, {title: "updated"}, @discussion)
end

Then(/^my followed threads should include the discussion$/) do
  @discussions = GroupDiscussionsViewer.for(user: @user).following
  @discussions.should include(@discussion)
end

Given(/^I am following by default in a group$/) do
  @group.membership_for(@user).update_attribute(:following_by_default, true)
end

When(/^there is a discussion created by someone in the group$/) do
  @discussion = FactoryGirl.build(:discussion, group: @group)
  DiscussionService.start_discussion(@discussion)
end

Given(/^I have set my preferences to email me activity I'm following$/) do
  @user.update_attribute(:email_followed_threads, true)
end

Given(/^I am following the group$/) do
  @group.membership_for(@user).update_attribute(:following_by_default, true)
end

Given(/^I am not following the group$/) do
  @group.membership_for(@user).update_attribute(:following_by_default, false)
end

Given(/^I click "(.*?)" on the group page$/) do |arg1|
  visit group_path(@group)
  click_on arg1
end

Then(/^I should get an email about the new discussion$/) do
  ActionMailer::Base.deliveries.last.to.should include @user.email
  ActionMailer::Base.deliveries.last.subject.should == @discussion.title
end

Then(/^I should not get an email about the new discussion$/) do
  @current_user = @user
  step('I should receive no emails')
end

Given(/^there is a discussion I have never seen before$/) do
  @discussion = FactoryGirl.build :discussion, group: @group
  DiscussionService.start_discussion @discussion
end

Given(/^there are no emails waiting for me$/) do
  ActionMailer::Base.deliveries = []
end

Then(/^I should be following new discussions by default$/) do
  @group.membership_for(@user).following_by_default.should == true
end

Then(/^I should not be following discussions by default$/) do
  @group.membership_for(@user).following_by_default.should == false
end

Given(/^I get mentioned in a discussion$/) do
  @comment = FactoryGirl.build(:comment, discussion: @discussion, body: "hi @#{@user.username}")
  DiscussionService.add_comment(@comment)
end

Given(/^there is a discussion I have unfollowed$/) do
  @discussion = FactoryGirl.build :discussion, group: @group
  DiscussionService.start_discussion @discussion
  DiscussionReader.for(discussion: @discussion, user: @user).unfollow!
end

Given(/^there is a discussion I am following$/) do
  @discussion = FactoryGirl.build :discussion, group: @group
  DiscussionService.start_discussion @discussion
  DiscussionReader.for(discussion: @discussion, user: @user).follow!
end

When(/^there is a subsequent comment in the discussion$/) do
  @comment = FactoryGirl.build(:comment, discussion: @discussion, body: "yea i know")
  DiscussionService.add_comment(@comment)
end

Then(/^I should be emailed the comment$/) do
  @current_user = @user
  step("I open the email with text \"#{@comment.body}\"")
end

Given(/^I click 'Following' on the discussion page$/) do
  visit discussion_path @discussion
  click_on "Following"
end

Given(/^Dr Follow By Email wants to be emailed new threads and activity he is following$/) do
  @dr_follow_by_email = FactoryGirl.create(:user,
                                           name: 'Dr Follow By Email',
                                           email_followed_threads: true,
                                           new_discussion_and_proposal_notifications_enabled: true)
  @group.add_member! @dr_follow_by_email
end

Given(/^Dr Follow By Email is following everything in this group$/) do
  @dr_follow_by_email.memberships.last.update_attribute(:following_by_default, true)
end

Given(/^Mr New Threads Only only wants to be emailed about new discussions and proposals$/) do
  @mr_new_threads_only = FactoryGirl.create(:user,
                                            email_followed_threads: false,
                                            name: 'Mr New Threads Only',
                                            new_discussion_and_proposal_notifications_enabled: true)
  @group.add_member! @mr_new_threads_only
end

Given(/^Mrs No Email Please does not want to be emailed about anything$/) do
  @mrs_no_email_please = FactoryGirl.create(:user,
                                            email_followed_threads: false,
                                            name: 'Mrs No Email Please',
                                            new_discussion_and_proposal_notifications_enabled: false)
  @group.add_member! @mrs_no_email_please
end

When(/^I start a new discussion$/) do
  reset_mailer
  @discussion = FactoryGirl.build :discussion, author: @user, group: @group
  @event = DiscussionService.start_discussion @discussion
end

Then(/^"(.*?)" should be emailed$/) do |name|
  email = User.find_by_name(name).email
  step "\"#{email}\" should receive an email"
end

Then(/^"(.*?)" should not be emailed$/) do |name|
  email = User.find_by_name(name).email
  step "\"#{email}\" should receive no emails"
end

Then(/^I should not be emailed$/) do
  email = @user.email
  step "\"#{email}\" should receive no emails"
end

When(/^I add a comment$/) do
  step 'I start a new discussion'
  reset_mailer
  @comment = FactoryGirl.build :comment, discussion: @discussion, body: "yea i know", author: @user
  @add_comment_event = DiscussionService.add_comment @comment
end

When(/^I mention Mr New Threads Only$/) do
  step 'I start a new discussion'
  reset_mailer
  @comment = FactoryGirl.build :comment, discussion: @discussion, author: @user,
                               body: "yea @#{@mr_new_threads_only.username}"
  @add_comment_event = DiscussionService.add_comment(@comment)
  @user_mentioned_event = Event.where(kind: 'user_mentioned').last
end

Then(/^"(.*?)" should be notified but not emailed about the new mention$/) do |name|
  step "\"#{name}\" should not be emailed"
  mentioned_user = User.find_by_name(name)
  @user_mentioned_event.notifications.where(user_id: mentioned_user.id).should exist
end

Then(/^"(.*?)" should be emailed and notified about the proposal closing soon$/) do |name|
  step "\"#{name}\" should be emailed"
  user = User.find_by_name(name)
  @motion_closing_soon_event.notifications.where(user_id: user.id).should exist
end

Then(/^"(.*?)" should be notified but not emailed about the proposal closing soon$/) do |name|
  step "\"#{name}\" should not be emailed"
  user = User.find_by_name(name)
  @motion_closing_soon_event.notifications.where(user_id: user.id).should exist
end

Then(/^I should be emailed and notified that the proposal closed$/) do
  step "\"#{@user.name}\" should be emailed"
  @motion_closed_event.notifications.where(user_id: @user.id).should exist
end

Then(/^I should be emailed and notified about the proposal closing soon$/) do
  step "\"#{@user.name}\" should be emailed and notified about the proposal closing soon"
end

When(/^I start a new proposal$/) do
  step 'I start a new discussion'
  reset_mailer
  @motion = FactoryGirl.build :motion, discussion: @discussion, author: @user
  @start_motion_event = MotionService.start_motion(@motion)
end

When(/^I vote on the proposal$/) do
  step 'I start a new proposal'
  reset_mailer
  @vote = FactoryGirl.build :vote, motion: @motion, user: @user
  @cast_vote_event = MotionService.cast_vote @vote
end

When(/^my proposal is about to close$/) do
  step 'I start a new discussion'
  @motion = FactoryGirl.build :motion, discussion: @discussion, author: @user
  MotionService.start_motion(@motion)
  reset_mailer
  @motion_closing_soon_event = Events::MotionClosingSoon.publish! @motion
end

When(/^my proposal closes$/) do
  step 'I start a new proposal'
  reset_mailer
  @motion_closed_event = MotionService.close(@motion)
end

Then(/^all the existing threads should be unfollowed$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^my inbox should only show unread content since the day I joined$/) do
  pending # express the regexp above with the code you wish you had
end
