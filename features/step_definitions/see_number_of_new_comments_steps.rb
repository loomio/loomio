Given /^there is a discussion in a group I belong to$/ do
  @group = FactoryGirl.create :group
  @discussion = FactoryGirl.create :discussion, :group => @group
  @group.add_member! @user
end

Given /^I have never read the discussion before$/ do
end

Given /^the discussion has comments$/ do
  @commenter = FactoryGirl.create :user
  @group.add_member! @commenter
  @discussion.add_comment @commenter, "hey there"
  @discussion.add_comment @commenter, "how are you"
end

When /^I visit the dashboard$/ do
  visit root_path
end

Then /^I should see the number of new comments the discussion has$/ do
  find(".activity-count").should have_content("2")
end

Then /^I should see the number of comments the discussion has$/ do
  step 'I should see the number of new comments the discussion has'
end

Given /^I have read the discussion before$/ do
  step 'the discussion has comments'
  visit discussion_path(@discussion)
end

Given /^the discussion has had new comments since I last read it$/ do
  step 'the discussion has comments'
end

When /^I visit the group page$/ do
  visit group_path(@group)
end
