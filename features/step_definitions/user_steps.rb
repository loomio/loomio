Given /^"(.*?)" is a user$/ do |email|
  FactoryGirl.create :user, :email => email, angular_ui_enabled: false
end

Given /^"(.*?)" is an existing user$/ do |arg1|
  user = FactoryGirl.create :user, name: arg1,
                            email: "#{arg1}@example.org",
                            angular_ui_enabled: false
end

Given /^I am an existing Loomio user$/ do
  @user = FactoryGirl.create :user, angular_ui_enabled: false
end

Given /^I am logged in$/ do
  @user ||= FactoryGirl.create :user, selected_locale: :en, angular_ui_enabled: false
  login_automatically @user
end

Given /^I speak English$/ do
  @user.update_attributes(selected_locale: :en)
end

Given /^I speak French$/ do
  @user.update_attributes(selected_locale: :fr) 
end

Given /^I prefer markdown$/ do
  @user.update_attributes(uses_markdown: true)
end

Given /^I don't prefer markdown$/ do
  @user.update_attributes(uses_markdown: false)
end
