When /^I choose to edit the discussion description$/ do
  click_link("edit_description")
end

When /^I fill in and submit the discussion description form$/ do
  description_text_markdown = "This discussion is more interesting with _this markdown_"
  fill_in "wmd-input-discussion-description", :with  => description_text_markdown
  click_on("add-description-submit")
end

Then /^I should see the description change$/ do
  description_text_rendered = "This discussion is more interesting with this markdown"
  find('#discussion-context').should have_content(description_text_rendered)
end

Then /^I should see a record of my change in the discussion feed$/ do
  find('#activity-feed').should have_content('changed the discussion description')
end

Then /^I should not see a link to edit the description$/ do
  page.should_not have_css("edit_description")
end

Given /^there is a discussion in a group$/ do
  @group = FactoryGirl.create :group
  @discussion = FactoryGirl.create :discussion, :group => @group
end

Then(/^I should not see a link to revision history$/) do
  page.should_not have_css(".see-revision-history")
end

Then(/^I should see a link to revision history$/) do
  page.should have_css(".see-revision-history")
end

