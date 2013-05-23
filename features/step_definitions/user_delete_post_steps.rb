Given(/^the discussion has a comment$/) do
  @commenter = FactoryGirl.create :user
  @group.add_member! @commenter
  @discussion.add_comment @commenter, "post to be deleted", false
end

When /^I click the delete button on a post$/ do
  click_link 'Delete'
end

And /^I accept the popup to confirm$/ do
  find('#confirm-action').click()
end

Then /^I should no longer see the post in the discussion$/ do
  find('#activity-feed').should_not have_content('post to be deleted')
end

Then /^I should not see the delete link on another users comment$/ do
  find('#activity-feed').should_not have_content('Delete')
end
