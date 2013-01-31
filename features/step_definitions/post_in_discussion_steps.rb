Given /^there is a comment in a public discussion$/ do
  @comment = FactoryGirl.create :comment
  @discussion = @comment.discussion
end

When /^I write and submit a comment$/ do
  @comment_text = 'Test comment'
  @comment_markdown_text = ' and also _markdown_'
  fill_in 'new-comment', with: @comment_text+@comment_markdown_text
  click_on 'post-new-comment'
end

When /^I enable markdown$/ do
  click_on 'markdown-dropdown-link'
  click_on 'enable-markdown-link'
end

When /^I disable markdown$/ do
  click_on 'markdown-dropdown-link'
  click_on 'disable-markdown-link'
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

Then /^markdown should now be on by default$/ do
  page.should have_css('.markdown-on')
end

Then /^markdown should now be off by default$/ do
  page.should have_css('.markdown-off')
end

Then /^there should be an anchor for the comment$/ do
  page.should have_css("#comment-#{@comment.id}")
end

Then /^I should see a permalink to the anchor for that comment$/ do
  find('#comment-#{@comment.id}-permalink')[:href].should == discussion_path(@discussion) + "#comment-#{@comment.id}"
end
