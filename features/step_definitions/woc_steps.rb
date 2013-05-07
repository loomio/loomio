Given /^there is a WocOptions record$/ do
  WocOptions.create(:example_discussion_url => 'http://google.com')
end

When /^I load woc index$/ do

  visit '/collaborate'
end

Then /^I should see the woc index$/ do
  page.should have_content 'Wellington Online Collaboration'
end
