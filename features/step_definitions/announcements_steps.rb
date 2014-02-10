Given /^there is an announcement$/ do
  Announcement.create! message: "loomio is great",
    starts_at: Time.zone.now - 1.day, ends_at: Time.zone.now + 1.day
end

When /^I load the dashboard$/ do
  visit dashboard_path
end

Then /^I should see the announcement$/ do
  page.should have_content 'loomio is great'
end

When /^I dismiss the announcement$/ do
  find('.close.dismiss-announcement').click()
end

When /^I reload the dashboard$/ do
  visit dashboard_path
end

Then /^I should not see the announcement$/ do
  page.should_not have_content 'I am an announcement'
end

And (/^I recieve an email with an invitation link$/) do
  open_email("furry@example.com")
  @invitation = Invitation.find_by_recipient_email("furry@example.com")
  current_email.should have_content(invitation_path(@invitation))
end

When(/^I click the link in the group setup email$/) do
  open_email("furry@example.com")
  link = links_in_email(current_email)[2]
  request_uri = URI::parse(link).request_uri
  visit request_uri
end
