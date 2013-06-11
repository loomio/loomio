Given(/^I edit a discussion description twice in quick succession$/) do
  visit discussion_path(@discussion)
  click_link("edit_description")
  description_text = "This discussion is more interesting with _this markdown_"
  fill_in "description-input", :with  => description_text
  click_on("add-description-submit")
  visit discussion_path(@discussion)
  click_link("edit_description")
  fill_in "description-input", :with  => description_text
  click_on("add-description-submit")
  visit discussion_path(@discussion)
end

Then(/^I should only see one activity item in the discussion activity feed$/) do
  page.all(".discussion-icon").count.should == 3
end
