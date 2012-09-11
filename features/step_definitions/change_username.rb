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
  User.where(:name => "new_username")
end

When /^I enter my current username$/ do
  fill_in "user_name", with: "furry"
end

Then /^my username stays the same$/ do
  User.where(:name=> "new_username").size ==1
end

When /^the username is taken$/ do
  User.where(:name => "new_username") ==1
end

Then /^my username is not changed$/ do
  not User.where(:name => "new_username")
end