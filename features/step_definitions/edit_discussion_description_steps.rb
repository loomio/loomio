When /^I choose to edit the discussion description$/ do
  find(".edit-discussion-description").click
end

When /^I fill in and submit the discussion description form$/ do
  @discussion_description_text = "This is all about myself"
  fill_in "description-input", :with => @discussion_description_text
  click_on "add-description-submit"
end

Then /^I should see the new discussion description$/ do
  find("#discussion-context").should have_content(@discussion_description_text)
end
