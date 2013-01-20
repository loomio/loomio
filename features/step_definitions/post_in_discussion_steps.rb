When /^I write and submit a comment$/ do
  @comment_text = 'Test comment'
  fill_in 'new-comment', with: @comment_text
  click_on 'post-new-comment'
end

Then /^a comment should be added to the discussion$/ do
  page.should have_content(@comment_text)
end

Given /^there is a comment in a public discussion$/ do
  @comment = FactoryGirl.create :comment
  @discussion = @comment.discussion
end

Then /^there should be an anchor for the comment$/ do
  page.should have_css("#comment-#{@comment.id}")
end

Then /^I should see a permalink to the anchor for that comment$/ do
  find('#comment-#{@comment.id}-permalink')[:href].should == discussion_path(@discussion) + "#comment-#{@comment.id}"
end
