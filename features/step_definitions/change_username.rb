When /^I am on the settings page$/ do
  visit "/settings"
end

When /^I enter my desired username$/ do
  fill_in 'user_name', with: "new_username"
end

When /^the username is not taken$/ do
  User.where(:name => "new_username").size==0
end

Then /^my username is changed$/ do
  page.should have_content "Your settings have been updated" # express the regexp above with the code you wish you had
end

When /^I enter my current username$/ do
  fill_in "user_name", with: current_user.name
end

Then /^my username stays the same$/ do
  current_user.name == "new_username"
end

When /^the username is taken$/ do
  User.where(:name => "new_username") ==1
end

Then /^my username is not changed$/ do
 page.should have_content "Your settings did not get updated"
end



