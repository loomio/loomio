Then(/^I should see the discussion title, context, and author$/) do
  page.should have_content @discussion.title
  page.should have_content @discussion.author_name
  page.should have_content @discussion.description
end
