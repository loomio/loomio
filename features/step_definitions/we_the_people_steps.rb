Given(/^there is a We The People campaign record$/) do
  @group = FactoryGirl.create :group, name: "We The People Groupy"
  @campaign = Campaign.create(name: "we the people",
                  manager_email: "contact@loomio.org",
                  showcase_url: group_path(@group))
end

When(/^I load We The People index$/) do
  visit we_the_people_path
end

Then(/^I should see the We The People index$/) do
  page.should have_content 'We The People'
end

When(/^I fill in and submit the form with my name and email$/) do
  pending
  @email = "goobly@joobly.com"
  fill_in "requested_name", with: "Goobly"
  fill_in "requested_email", with: @email
  click_on "Send request"
end

Then(/^I should see the We The People group page$/) do
  page.should have_content(@group.name)
end

Then(/an email should be sent to the campaign manager$/) do
  step "\"#{@campaign.manager_email}\" should receive an email"
end

Then(/^a campaign signup should be saved$/) do
  CampaignSignup.find_by_email(@email).should_not be_nil
end
