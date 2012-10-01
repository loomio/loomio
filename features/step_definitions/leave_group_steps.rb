Given /^I am logged in as a non admin user of the group$/ do
  @groupname = "demo-group"
  @non_admin_user = "non-admin-user@loom.io"
  @admin_user = "admin-user@loom.io"

  step %{a group named "#{@groupname}" exists} 
  step %{"#{@admin_user}" is an admin member of group "#{@groupname}"}
  step %{"#{@non_admin_user}" is a non-admin member of group "#{@groupname}"}
  step %{I am logged in as "#{@non_admin_user}"}
end

When /^I leave the group$/ do
  step %{I visit the group page for "#{@groupname}"}
  step 'I click "Options"'
  step 'I click "Leave group"'
  step 'I accept popup'
end

Then /^I should be removed from the group$/ do
  step %{I should see "You have left #{@groupname}"}
end