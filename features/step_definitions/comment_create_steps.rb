When /^I write and submit a comment$/ do
  @comment_text = 'Test comment,'
  @comment_markdown_text = ' also i like http://xkcd.org and also _markdown_'
  fill_in 'wmd-input-comment', with: @comment_text+@comment_markdown_text
  click_on 'post-new-comment'
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

Then /^there should be an anchor for the comment$/ do
  page.should have_css("#comment-1")
end

Then /^I should see a permalink to the anchor for that comment$/ do
  find('.activity-item-time a[href="#comment-1"]').should be_present
end

Then /^the comment should autolink links$/ do
  page.should have_link('xkcd.org', {:href => 'http://xkcd.org'})
end
