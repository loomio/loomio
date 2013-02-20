When /^I write and submit a comment$/ do
  @comment_text = 'Test comment,'
  @comment_markdown_text = ' also i like http://xkcd.org and also _markdown_'
  @comment_markdown_always = " \n newlines should be ignored \n \n yepp"
  fill_in 'new-comment', with: @comment_text+@comment_markdown_text+@comment_markdown_always
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
  page.should have_css("#comment-2")
end

Then /^I should see a permalink to the anchor for that comment$/ do
  find('.activity-item-time a')[:href].should == "#comment-2"
end

Then /^the comment should autolink links$/ do
  page.should have_link('xkcd.org', {:href => 'http://xkcd.org', :target => '_blank'})
end

Then /^the comment should include appropriate new lines$/ do
  page.should have_css(".activity-item-header p")
end
