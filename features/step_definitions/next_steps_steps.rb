Then(/^I should see the next_steps panel$/) do
  page.should have_css('#setup-next-steps')
end

Then(/^I should not see the next_steps panel$/) do
  page.should_not have_css('#setup_next_steps')
end

Given(/^I dismiss the next_steps panel$/) do
  find('.hide-next-steps').click()
end