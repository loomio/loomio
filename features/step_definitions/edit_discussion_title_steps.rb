When /^I choose to edit the discussion title$/ do
  find("#options-dropdown").click
  find(".edit-discussion").click
end

When /^I fill in and submit the discussion title form$/ do
  @title_text = "Better title"
  fill_in "discussion_title", :with  => @title_text
  find("#discussion-submit").click
end

Then /^I should see the new title$/ do
  find('#discussion-title').should have_content(@title_text)
end

Then /^I should see a record of my title change in the discussion feed$/ do
  page.should have_content(@title_text)
end

Given /^I am not an admin of this group$/ do
end

Then /^I should not see a link to edit the title$/ do
  page.should_not have_css("options-dropdown")
end
