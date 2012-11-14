When /^I click "(.*?)"$/ do |arg1|
  click_on arg1
end

When /^I check "(.*?)"$/ do |arg1|
  check arg1
end

Then /^I should see "(.*?)"$/ do |arg1|
  page.should have_content(arg1)
end

Then /^I should not see "(.*?)"$/ do |arg1|
  page.should_not have_content(arg1)
end

Then /^I should not see "(.*?)" link$/ do |arg1|
  page.should_not have_link(arg1)
end

When /^I accept popup$/ do
  page.driver.browser.switch_to.alert.accept
end
