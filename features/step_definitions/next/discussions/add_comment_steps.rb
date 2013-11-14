Given(/^I am looking the mobile version of the discussion$/) do
  visit "/next/discussions/#{@discussion.id}"
end

When(/^I click on the add comment box$/) do
  page.find('.fake input').click
end

When(/^I enter a comment and post it$/) do
  fill_in 'comment-field', with: 'hello im in angular'
  click_on('post-comment-btn')
end

Then(/^I should see the comment added to the discussion$/) do
  page.find('.comment').should have_content('hello im in angular')
end
