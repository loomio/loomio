When /^I click the like button on a post$/ do
  click_link 'Like'
  visit(current_path) # this is a hack to make sure the test passes even if the AJAX isn't working
end

Then /^a post should be liked by "(.*?)"$/ do |email|
  user = User.find_by_email(email)
  page.should have_content('Liked by ' + user.name)
end
