Given /^I am logged in as "(.*?)"$/ do |email|
  login(email, 'password')
end

When /^I login as "(.*?)"$/ do |email|
  login(email, 'password')
end

Then /^I should be logged in$/ do
  page.should have_css "body.dashboard.show"
end

Then /^I should not be logged in$/ do
  page.should have_content "Invalid email or password"
end

When /^I login as "(.*?)" with an incorrect password$/ do |email|
  visit "/user/sign_in"
  page.should have_content "sign in"
  fill_in 'user_email', with: email
  fill_in 'user_password', with: "wrong_password"
  click_on "Sign in"
end
