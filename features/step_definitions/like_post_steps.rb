When /^I click the like button on a post$/ do
  click_link 'Like'
end

When /^I click the unlike button on a post$/ do
  click_link 'Unlike'
end

Then /^a post should be liked by "(.*?)"$/ do |email|
  user = User.find_by_email(email)
  page.should have_content('Liked by ' + user.name)
end
Then /^I should not see any liked posts by "(.*)"$/ do |email|
  user = User.find_by_email(email)
  page.should_not have_content('Liked by ' + user.name)
end
