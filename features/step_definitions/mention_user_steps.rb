When /^I mention "(.*?)" in my comment$/ do |arg1|
  fill_in 'new-comment', with: arg1[0,1]
end

Then /^I should Should see a pop up for mentioning "(.*?)"$/ do |arg1|
  page.should have_content('Mention ' + arg1) # this can be tailored depending on how we want to show it
end

Then /^I should be able to mention "(.*?)"$/ do |arg1|
  click_button('mention-user')
end