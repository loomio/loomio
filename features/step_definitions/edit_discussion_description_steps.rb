When /^I choose to edit the discussion description$/ do
  click_link("edit_description")
end

When /^I fill in and submit the discussion description form$/ do
  @description_text = "This discussion is more interesting with _this markdown_"
  fill_in "description-input", :with  => @description_text
  click_on("add-description-submit")
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
  @discussion = FactoryGirl.create :discussion, :group => @group
end
