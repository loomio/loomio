When(/^I visit the inbox$/) do
  visit inbox_path
end

Given(/^I belong to a group with a discussion$/) do
  @group = FactoryGirl.create :group
  @author = FactoryGirl.create :user
  @group.add_member!(@user)
  @group.add_member!(@author)
  @discussion = FactoryGirl.build :discussion, group: @group
  DiscussionService.create(discussion: @discussion, actor: @author)
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
  @group = FactoryGirl.create(:group)
  @group.add_member!(@user)
  @discussion = FactoryGirl.create(:discussion, group: @group)
  @motion = FactoryGirl.create(:motion, discussion: @discussion)
  @group = @motion.group
end

Then(/^I should see the motion$/) do
  page.should have_content(@motion.title)
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
  @group = FactoryGirl.create :group
  @group.add_member!(@user)
  @discussion = FactoryGirl.build :discussion, group: @group
  DiscussionService.create(discussion: @discussion, actor: @user)
  @discussion2 = FactoryGirl.build :discussion, group: @group
  DiscussionService.create(discussion: @discussion2, actor: @user)
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
  @discussion.group.add_member!(@discussion.author)
  DiscussionReader.for(user:@user, discussion: @discussion).viewed!
  @comment = FactoryGirl.build(:comment, discussion: @discussion)
  CommentService.create(comment: @comment, actor: @user, mark_as_read: false)
end

Given(/^I belong to a group with more than max per inbox group discussions$/) do
  @group = FactoryGirl.create :group
  @group.add_member!(@user)
  Inbox::UNREAD_PER_GROUP_LIMIT = 3
  4.times do
    @discussion = FactoryGirl.build :discussion, group: @group
    DiscussionService.create(discussion: @discussion, actor: @user)
  end
end

When(/^I click 'clear them all'$/) do
  click_on 'mark them all as read'
end

Then(/^all the discussions in the group should be marked as read$/) do
  sleep(1)
  expect(Queries::VisibleDiscussions.new(user: @user, groups: [@group]).unread.size).to eq 0
end
