Given /^I am an admin of this group$/ do
  @group.add_admin!(@user)
end

When /^I select the delete discussion link from the discussion dropdown$/ do
  find("#options-dropdown").click
  click_on "Delete discussion"
end

Then /^I should be directed to the group page$/ do
  page.should have_css("body.groups.show")
end

Then /^I should not see the discussion in the list of discussions$/ do
  page.should_not have_content(@discussion)
end

Then /^I should see a message notifying me of the deletion$/ do
  page.should have_content('Discussion successfully deleted.')
end

When /^I should not see the delete discussion link in the discussion dropdown$/ do
  page.should_not have_css('#options-dropdown')
end
