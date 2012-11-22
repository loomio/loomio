When /^I write and submit a comment$/ do
  fill_in 'new-comment', with: 'Test comment'
  click_on 'post-new-comment'
end

Then /^a comment should be added to the discussion "(.*?)"$/ do |title|
  Discussion.where(:title => title).first.comments.size.should == 1
end
