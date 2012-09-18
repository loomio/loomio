Given /^I am on the discussion page$/ do
  visit '/discussions/' + Discussion.last.id.to_s
end

When /^I write and submit a comment$/ do
  fill_in 'new-comment', with: 'Test comment'
  click_on 'post-new-comment'
end

Then /^a comment is added to the discussion$/ do
  Comment.where(:commentable_id => Group.last.id, :body => 'Test comment', :user_id => User.last.id).size > 0
end