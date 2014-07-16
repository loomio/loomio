When(/^I visit the import contacts page$/) do
  visit import_contacts_path
  save_and_open_page
end

When(/^I import my gmail contacts$/) do
end

Then(/^I should have some contacts$/) do
  @user.contacts.should_not be_empty
end

