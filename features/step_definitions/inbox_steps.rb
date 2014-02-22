When(/^I visit the inbox$/) do
  visit inbox_path
end

Given(/^I belong to a group with a discussion$/) do
  @discussion = create_discussion
  @group = @discussion.group
  @group.add_member!(@user)
end

When(/^I click to view the discussion$/) do
  click_on(@discussion.title)
end

When(/^I visit the inbox again$/) do
  step 'I visit the inbox'
end

Then(/^the inbox should be empty$/) do
  page.should have_content(I18n.t(:"inbox.empty"))
end

Then(/^I should see the unread discussion$/) do
  page.should have_content(@discussion.title)
end

Given(/^I belong to a group with a motion$/) do
  @motion = FactoryGirl.create(:motion)
  @group = @motion.group
  @group.add_member!(@user)
end

Then(/^I should see the motion$/) do
  page.should have_content(@motion.title)
end

When(/^I have voted on the motion$/) do
  @motion.discussion.as_read_by(@user).viewed!
  vote = Vote.new(position: "yes")
  vote.motion = @motion
  vote.user = @user
  vote.save!
  @motion.as_read_by(@user).viewed!
end

When(/^I mark the discussion as read$/) do
  find('.mark-as-read-btn a').click
end

Then(/^the discussion should disappear$/) do
  page.should_not have_content @discussion.title
end

When(/^I mark the discussion as hidden$/) do
  click_on :'unfollow-btn'
end

Then(/^the discussion should not show in inbox$/) do
  page.should_not have_content @discussion.title
end

When(/^I mark the motion as read$/) do
  find('.motion .mark-as-read-btn a').click
end

Then(/^the motion should disappear$/) do
  page.should_not have_content @motion.title
end

Given(/^I belong to a group with several discussions$/) do
  @discussion = create_discussion
  @group = @discussion.group
  @group.add_member!(@user)
  @discussion2 = create_discussion group: @group
end

When(/^I click 'Clear'$/) do
  click_on 'Clear'
end

Then(/^the discussions should disappear$/) do
  page.should_not have_content @discussion.title
  page.should_not have_content @discussion2.title
end

Then(/^I should see the discussion has (\d+) unread$/) do |arg1|
  find('.activity-badge').should have_content arg1
end

Given(/^I have read the discussion but there is a new comment$/) do
  DiscussionReader.for(user:@user, discussion: @discussion).viewed!
  @discussion.group.add_member!(@discussion.author)
  @comment = Comment.new(body: 'hi')
  @comment.author = @user
  @comment.discussion = @discussion
  DiscussionService.add_comment(@comment)
end

Given(/^I belong to a group with more than max per inbox group discussions$/) do
  @discussion = create_discussion
  @group = @discussion.group
  @group.add_member!(@user)
  Inbox::UNREAD_PER_GROUP_LIMIT.times do
    create_discussion group: @group
  end
end

When(/^I click 'clear them all'$/) do
  click_on 'mark them all as read'
end

Then(/^all the discussions in the group should be marked as read$/) do
  sleep(1)
  Queries::VisibleDiscussions.new(user: @user, groups: [@group]).unread.size.should == 0
end

When(/^I join a group$/) do
  @group = FactoryGirl.create(:group)
  @old_discussion = create_discussion group: @group, created_at: 3.weeks.ago, last_comment_at: 3.weeks.ago
  @motion = FactoryGirl.create(:motion, discussion: @old_discussion)
  @new_discussion = create_discussion group: @group, created_at: 2.hours.ago, last_comment_at: 2.hours.ago
  @group.add_member!(@user)
end

Then(/^I should only see that groups recent discussions and current motions$/) do
  page.should_not have_content @old_discussion.title
  page.should have_content @motion.title
  page.should have_content @new_discussion.title
end

