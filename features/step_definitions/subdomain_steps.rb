Given(/^there is a group with a subdomain$/) do
  @theme = Theme.create(name: 'pizzatheme')
  @group = FactoryGirl.create(:group, subdomain: 'pizza', theme: @theme)
end

Given(/^I have a user account$/) do
  @user = FactoryGirl.create(:user)
end

When(/^I visit the site with that subdomain$/) do
  switch_to_subdomain('pizza')
  visit '/'
end

Then(/^I should see the group page for that group$/) do
  page.should have_css('body.groups.show')
  page.should have_content(@group.name)
end

When(/^I click the log in button$/) do
  click_on "Log in"
end

Then(/^I should see the subdomain login page$/) do
  page.should have_xpath("//link[contains(@href, '#{theme_assets_path(@theme)}.css')]", visible: false)
  page.should have_content "By clicking Log in, you agree to Loomio"
end

When(/^I login$/) do
  fill_in :user_email, with: @user.email
  fill_in :user_password, with: 'password'
  click_on 'Log in'
end

Then(/^I should see the subdomain group page$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I view a discussion$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see the discussion from that subdomain$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^I am on the root dashboard$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I visit a subdomained group$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should be on the subdomain$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^I am on the subdomain group page$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I visit a non subdomain group page$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should be on the root group page$/) do
  pending # express the regexp above with the code you wish you had
end
