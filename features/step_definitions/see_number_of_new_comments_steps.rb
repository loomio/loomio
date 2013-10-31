Given /^someone comments on the discussion$/ do
  @commenter = FactoryGirl.create :user
  @group.add_member! @commenter
  @comment = Comment.new(body: "hey there")
  AddCommentService.new(@commenter, @comment, @discussion).commit!
end

When /^I visit the dashboard$/ do
  visit root_path
end

Then(/^I should see that the discussion has (\d+) unread$/) do |arg1|
  find(".activity-count").should have_content(arg1)
end

Then /^I should see the number of comments the discussion has$/ do
  step 'I should see the number of new comments the discussion has'
end

Given /^I read the discussion when it was uncommented$/ do
  @discussion.as_read_by(@user).viewed!
end

Given /^the discussion has had new comments since I last read it$/ do
  step 'the discussion has a comment'
end

When /^I visit the group page$/ do
  visit group_path(@group)
end
