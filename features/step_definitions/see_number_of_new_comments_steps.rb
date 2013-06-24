Given /^I have never read the discussion before$/ do
end

Given /^the discussion has comments$/ do
  @commenter = FactoryGirl.create :user
  @group.add_member! @commenter
  @discussion.add_comment @commenter, "hey there", false
  @discussion.add_comment @commenter, "how are you", false
end

When /^I visit the dashboard$/ do
  visit root_path
end

Then(/^I should see that the discussion has (\d+) new comments$/) do |arg1|
  find("#discussion-preview-#{@discussion.id} .activity-count").should have_content(arg1)
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
