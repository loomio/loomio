When /^I choose to edit the discussion title$/ do
  find("#options-dropdown").click
  click_link("edit-title")
end

When /^I fill in and submit the discussion title form$/ do
  @title_text = "Better title"
  fill_in "discussion-input", :with  => @title_text
  click_on("edit-title-submit")
end

Then /^I should see the title change$/ do
  find('#discussion-title').should have_content(@title_text)
end

Then /^I should see a record of my title change in the discussion feed$/ do
  find('#activity-list').should have_content(@title_text)
end

Given /^I am not an admin of this group$/ do
end

Then /^I should not see a link to edit the title$/ do
  page.should_not have_css("options-dropdown")
end
