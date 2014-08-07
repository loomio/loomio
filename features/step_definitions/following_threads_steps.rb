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
