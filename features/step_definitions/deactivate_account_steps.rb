When(/^I click the deactivate account button$/) do
  click_on 'deactivate-user-account'
end

Then(/^I should see the sign\-in page$/) do
  page.should have_css('body.pages.sessions.new')
end

Then(/^I should see confirmation that my account has been deactivated$/) do
  page.should have_content('This account has been deactivated.')
end

Then(/^I should be told that I cannot deactivate my account$/) do
  page.should have_content('A group must have at least one coordinator')
end
