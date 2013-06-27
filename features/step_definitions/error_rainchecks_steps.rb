When(/^I visit the not_found_path and see the error_rainchecks error page$/) do
  visit not_found_path(@not_found_path)
  page.should have_content("We're sorry, but something went wrong.")
end

When(/^I submit a valid email address$/) do
  fill_in 'error_raincheck_email', with: "blah@jah.com"
  find('#error-raincheck-submit').click
end

Then(/^I should see the thank you page$/) do
  page.should have_content("Thank you!")
end

And(/^I should be able to click the 'return to home page' link$/) do
  click_on("Return to home page")
end

Then(/^I should see the dashboard$/) do
  page.should have_content("Request New Group")
end

Given(/^I am a Loomio admin$/) do
  @user = FactoryGirl.create :user, :is_admin => true
end

And(/^I visit the Error Rainchecks in the admin panel$/) do
  visit admin_error_raincheck_path(@error_raincheck)
end



