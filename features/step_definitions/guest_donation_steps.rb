When(/^I visit the home page$/) do
  visit root_path
end

When(/^I click the donate tab$/) do
  find("#donate-container > a").click
end
