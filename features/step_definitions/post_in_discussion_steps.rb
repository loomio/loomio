When /^I write and submit a comment$/ do
  @comment_text = 'Test comment'
  fill_in 'new-comment', with: @comment_text
  click_on 'post-new-comment'
end

Then /^a comment should be added to the discussion$/ do
  page.should have_content(@comment_text)
end
