Then /^I should not see the list of invited users$/ do
  page.should_not have_css('#invited-users')
end
