Given(/^I have a comment on the discussion$/) do
  @comment = FactoryGirl.build(:comment, discussion: @discussion, user: @user)
  CommentService.create(comment: @comment, actor: @comment.author)
end

When(/^I edit my comment$/) do
  visit edit_comment_path(@comment)
  fill_in :comment_body, with: 'I never declare!'
  click_on 'Update'
end

Then(/^I should see my comment has updated in the discussion$/) do
  page.should have_content 'I never declare!'
  page.should_not have_content 'I do declare!'
end

Given(/^there is an edited comment in the discussion$/) do
  @comment = FactoryGirl.build(:comment, discussion: @discussion, user: @user, body: 'I do declare')
  CommentService.create(comment: @comment, actor: @comment.author)
  @comment.update_attributes(body: 'I never declare!', edited_at: Time.zone.now)
end

When(/^I view the history of that comment$/) do
  visit discussion_path(@discussion)
  click_on 'Edited'
end

Then(/^I should see the old and new versions$/) do
  page.should have_content 'I do declare'
  page.should have_content 'I never declare'
end
