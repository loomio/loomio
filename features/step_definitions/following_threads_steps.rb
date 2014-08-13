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

Then(/^I should not get emailed the comment$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I am on the dashboard$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see both discussions$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I filter to only show followed content$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should only see the followed discussion$/) do
  pending # express the regexp above with the code you wish you had
end
