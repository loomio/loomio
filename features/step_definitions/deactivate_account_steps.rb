When(/^I click the deactivate account button$/) do
  click_on 'deactivate-user-account'
end

Then(/^I should be asked why I am deactivating my account$/) do
  page.should have_content("Would you mind telling us why you are deactivating your account?")
end

When(/^I provide a response and confirm my decision$/) do
  fill_in 'user_deactivation_response_body', with: 'Coz I want to'
  click_on 'account-deactivation-submit'
end

Then(/^I should see the sign\-in page with confirmation that my account has been deactivated$/) do
  page.should have_css('body.pages.sessions.new')
  page.should have_content('This account has been deactivated.')
end

Then(/^my deactivation_response attribute should be set$/) do
  @user.deactivation_response.should be_present
end

Then(/^I should be told that I cannot deactivate my account$/) do
  page.should have_content('A group must have at least one coordinator')
end
