Given /^I am an admin of this group$/ do
  @group.add_admin!(@user)
end

When /^I select the remove discussion link from the discussion dropdown$/ do
  find("#discussion-options").click
  click_on "remove-discussion"
end

When /^I confirm this action$/ do
  page.driver.browser.switch_to.alert.accept
end

Then /^I should be directed to the group page$/ do
  page.should have_css("body.groups.show")
end

Then /^I should not see the discussion in the list of discussions$/ do
  find('#group-discussions').should_not have_content(@discussion)
end

Then /^I should see a message notifying me of the removal$/ do
  page.should have_content('Discussion removed.')
end

Given /^I am not an admin of this group$/ do
  @group.add_member!(@user)
end

When /^I should not see the remove discussion link in the discussion dropdown$/ do
  find("#discussion-options").click
  page.should_not have_css('remove-discussion')
end