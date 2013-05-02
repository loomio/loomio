Given /^there is an announcement$/ do
  Announcement.create! message: "I am an announcement", 
    starts_at: 1.hour.ago, ends_at: 1.hour.from_now
end

When /^I load the dashboard$/ do
  visit '/'
end

Then /^I should see the announcement$/ do
  page.should have_content 'I am an announcement'
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
