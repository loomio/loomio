Given /^I am a registered User$/ do
  User.create(:email => "fluffy@example.com", :password =>"password", name=>"Fluffy")
  end

When /^I am on the login page$/ do
   within("#index") do
   fill_in 'Login', :with => 'user@example.com'
   fill_in 'Password', :with => 'password'
  end
end

When /^I enter my details$/ do
  pending # express the regexp above with the code you wish you had
end

When /^click submit$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I am logged in$/ do
  pending # express the regexp above with the code you wish you had
end

