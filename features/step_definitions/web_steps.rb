When /^I click "(.*?)"$/ do |arg1|
  click_on arg1
end

When(/^I click the element "(.*?)"$/) do |arg1|
  find(arg1).click
end

When /^I check "(.*?)"$/ do |arg1|
  check arg1
end

Then /^(?:I|they) should see "(.*?)"$/ do |arg1|
  page.should have_content(arg1)
end

Then /^I should not see "(.*?)"$/ do |arg1|
  page.should_not have_content(arg1)
end

Then /^I should not see "(.*?)" link$/ do |arg1|
  page.should_not have_link(arg1)
end

When /^I accept popup$/ do
  page.driver.browser.switch_to.alert.accept unless Capybara.javascript_driver == :poltergeist #poltergeist always confirms these
end

Then /^I would like to stop the test and look at it$/ do
  step 'debugger'
end

Then /^debugger$/ do
  debugger
end

And /^show me the page$/ do
  save_and_open_page
end

And /^screenshot$/ do
  step 'take a screenshot'
end

And /^take a screenshot$/ do
  if @screenshot_count
    @screenshot_count +=1
    file_name = "#{@feature_name}: #{@scenario_name} (#{@screenshot_count})"
  else
    @screenshot_count = 0
    file_name = "#{@feature_name}: #{@scenario_name}"
  end
  page.driver.render("tmp/screenshots/#{file_name}.png", full: true)
  puts '[SCREENSHOT]: written to tmp/screenshots'
end

And /^take a screenshot and name it "(.*?)"$/ do |arg1|
  page.driver.render("tmp/screenshots/cucumber_#{arg1}.png")
end
