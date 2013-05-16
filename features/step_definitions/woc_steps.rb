Given /^there is a WOC campaign record$/ do |name|
  @campaign = Campaign.create(name: name,
                  manager_email: "contact@loomio.org",
                  showcase_url: 'http://google.com')
end

When /^I load woc index$/ do
  visit '/collaborate'
end

Then /^I should see the woc index$/ do
  page.should have_content 'Wellington Online Collaboration'
end
