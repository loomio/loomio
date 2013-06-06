When /^I choose to edit the group description$/ do
  find("#edit_description").click
end

When /^I fill in and submit the group description form$/ do
  @description_text = "This group is interesting"
  fill_in "description-input", :with  => @description_text
  click_on("add-description-submit")
end

Then /^I should see the group description change$/ do
  find('.description-body').should have_content(@description_text)
end

Then /^I should not see a link to edit the group description$/ do
  page.should_not have_css("edit_description")
end
