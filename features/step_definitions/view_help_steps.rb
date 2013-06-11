When(/^I visit the help page$/) do
  visit help_path
end

Then(/^I should see some help$/) do
  page.should have_css("#how-it-works")
end
