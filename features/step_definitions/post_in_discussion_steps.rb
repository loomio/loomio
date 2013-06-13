When /^I write and submit a comment$/ do
  @comment_text = 'Test comment,'
  @comment_markdown_text = ' also i like http://xkcd.org and also _markdown_'
  @comment_markdown_always = " \n newlines should be ignored \n \n yepp"
  fill_in 'new-comment', with: @comment_text+@comment_markdown_text+@comment_markdown_always
  click_on 'post-new-comment'
end

When /^I enable comment markdown$/ do
  find('#comment-markdown-dropdown-link .markdown-icon').click
  find('#comment-markdown-dropdown .enable-markdown').click
end

When /^I disable comment markdown$/ do
  find('#comment-markdown-dropdown-link .markdown-icon').click
  find('#comment-markdown-dropdown .disable-markdown').click
end

Then /^a comment should be added to the discussion$/ do
  page.should have_content(@comment_text)
end

Then /^the comment should not format markdown characters$/ do
  page.should have_content(@comment_markdown_text)
end

Then /^I should not see new activity for the discussion$/ do
  pending 'for some reason this fails intermittently when you run the whole suite'
  find("#discussion-preview-#{@discussion.id}").should_not have_css(".activity-count")
end

Then /^the comment should format markdown characters$/ do
  page.should_not have_content(@comment_markdown_text)
end

Then /^comment markdown should now be on by default$/ do
  find('#content-comments').should have_css('.markdown-on')
end

Then /^comment markdown should now be off by default$/ do
  find('#content-comments').should have_css('.markdown-off')
end

Then /^there should be an anchor for the comment$/ do
  page.should have_css("#comment-2")
end

Then /^I should see a permalink to the anchor for that comment$/ do
  find('.activity-item-time a[href="#comment-2"]').should be_present
end

Then /^the comment should autolink links$/ do
  page.should have_link('xkcd.org', {:href => 'http://xkcd.org'})
end

Then /^the comment should include appropriate new lines$/ do
  page.should have_css(".activity-item-header p")
end
