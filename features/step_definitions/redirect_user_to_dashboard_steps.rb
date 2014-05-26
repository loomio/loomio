Then(/^I see the dashboard$/) do
  page.should have_css('body.dashboard')
end

Then(/^I see the frontpage$/) do
  page.should have_css('body.marketing')
end
