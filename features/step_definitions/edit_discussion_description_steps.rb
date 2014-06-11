When /^I choose to edit the discussion description$/ do
  click_on("Edit")
end

When /^I fill in and submit the discussion description form$/ do
  @description_text = "This discussion is more interesting with _this markdown_"
  fill_in "discussion_description", :with => @description_text
  click_on("discussion-submit")
end

Then /^I should see the description change$/ do
  find('#discussion-context').should have_content(@description_text)
end

Then /^I should see a record of my change in the discussion feed$/ do
  find('#activity-feed').should have_content('changed the discussion description')
end

Then /^I should not see a link to edit the description$/ do
  page.should_not have_css("edit_description")
end

Then /^my global markdown preference should still be 'disabled'$/ do
  find('#comment-markdown-dropdown').should have_css('.markdown-off')
end

Given /^there is a discussion in a group$/ do
  @group = FactoryGirl.create :group
  @discussion = create_discussion :group => @group
end

Then(/^I should not see a link to revision history$/) do
  page.should_not have_css(".see-revision-history")
end

Then(/^I should see a link to revision history$/) do
  page.should have_css(".see-revision-history")
end

