When /^I write and submit a comment$/ do
  @comment_text = 'Test comment'
  @comment_markdown_text = ' and also _markdown_'
  fill_in 'new-comment', with: @comment_text+@comment_markdown_text
  click_on 'post-new-comment'
end

Then /^a comment should be added to the discussion$/ do
  page.should have_content(@comment_text)
end

Then /^the comment should not format markdown characters$/ do
  page.should have_content(@comment_markdown_text)
end

Then /^the comment should format markdown characters$/ do
  page.should_not have_content(@comment_markdown_text)
end

When /^I enable markdown$/ do
  click_on 'markdown-dropdown-link'
  click_on 'enable-markdown-link'
end

When /^I disable markdown$/ do
  click_on 'markdown-dropdown-link'
  click_on 'disable-markdown-link'
end

Then /^markdown should now be on by default$/ do
  page.should have_css('.markdown-on')
end

Then /^markdown should now be off by default$/ do
  page.should have_css('.markdown-off')
end
