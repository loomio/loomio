Given /^there is an announcement$/ do
  Announcement.create! message: "loomio is great", 
    starts_at: Time.zone.now - 1.day, ends_at: Time.zone.now + 1.day
end

When /^I load the dashboard$/ do
  visit '/'
end

Then /^I should see the announcement$/ do
  page.should have_content 'loomio is great'
end

When /^I dismiss the announcement$/ do
  click_on 'Click here to dismiss this message'
end

When /^I reload the page$/ do
  visit '/'
end

Then /^I should not see the announcement$/ do
  page.should_not have_content 'I am an announcement'
end
