Given /^I am not logged in$/ do
end

When /^I visit the sign in page$/ do
  visit "/users/sign_in"
end

Given /^my browser language header is set to "(.*?)"$/ do |arg1|
  page.driver.headers = { "Accept-Language" => "#{arg1}" }
end

Given /^I have not set my language preference$/ do
  puts "language preference: #{@user.language_preference}"
end

Given /^my language preference is set to "(.*?)"$/ do |arg1|
  @user.update_attribute(:language_preference, arg1)
end

Given(/^"(.*?)"s language preference is set to "(.*?)"$/) do |arg1, arg2|
  user = User.find_by_email("#{arg1}@example.org")
  user.update_attribute(:language_preference, arg2)
end

Then /^I change my language preference to Espanol$/ do
  page.find_by_id('user_language_preference').find("option[value='es']").select_option
  page.find_by_id('user-settings-submit').click
end
