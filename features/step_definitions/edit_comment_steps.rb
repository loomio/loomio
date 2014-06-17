Given(/^I have a comment on the discussion$/) do
  @comment = @discussion.add_comment(@user, 'I do declare!')
end

When(/^I edit my comment$/) do
  visit edit_comment_path(@comment)
  fill_in :comment_body, with: 'I never declare!'
  click_on 'Save changes'
end

Then(/^I should see my comment has updated in the discussion$/) do
  page.should have_content 'I never declare!'
  page.should_not have_content 'I do declare!'
end

Given(/^there is an edited comment in the discussion$/) do
  @comment = @discussion.add_comment(@user, 'I do declare!')
  @comment.update_attributes(body: 'I always never delcare!')
end

When(/^I view the history of that comment$/) do
  click_on 'View changes'
end

Then(/^I should see a diff between the old and new versions$/) do
  page.should have_content 'I do declare!'
  page.should have_content 'I never declare!'
end
