When /^I click the like button on a post$/ do
  click_link 'Like'
end

Then /^a post is liked$/ do
  page.should have_content('Liked by ' + User.last.name)
end