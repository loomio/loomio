Given(/^the discussion has a comment$/) do
  @commenter = FactoryGirl.create :user
  @group.add_member! @commenter
  @comment = Comment.new(body: 'post to be deleted')
  @comment.author = @commenter
  @comment.discussion = @discussion
  CommentService.create(comment: @comment, actor: @comment.author)
end

When /^I click the delete button on a post$/ do
  find(".delete-icon").click()
end

And /^I accept the popup to confirm$/ do
  find('#confirm-action').click()
end

Then(/^I should see a representation of the deleted comment$/) do
  find('#activity-feed').should have_content('Deleted comment')
end

Then /^I should not see the delete link on another users comment$/ do
  find('#activity-feed').should_not have_content('Delete')
end

Then(/^I should be told the comment was deleted$/) do
  page.should have_content('Comment deleted.')
end
