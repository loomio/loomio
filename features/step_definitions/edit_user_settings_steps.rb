Given /^I visit the user settings page$/ do
  visit "/settings"
end

Then /^I should see my display name has been updated$/ do
  page.should have_content(@display_name)
end


Given /^I fill in and submit the new name$/ do
  find('#edit-name-link').click
  @display_name = Faker::Name.name
  fill_in 'user_name', with: @display_name
  click_on 'edit-name-submit'
end

Then /^I upload a profile image$/ do
  pending "TODO: write test for image upload"
end