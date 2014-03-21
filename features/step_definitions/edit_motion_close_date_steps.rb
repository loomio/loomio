Given /^I am an admin of a group with a discussion$/ do
  @group = FactoryGirl.create :group
  @discussion = create_discussion :group => @group
  @group.add_admin! @user
end

When /^I click the 'change close date' button$/ do
  click_on 'change-close-date'
end

When /^I select the new close date$/ do
  @close_date = 5.days.from_now + 12.hours
  fill_in "motion_close_at_date", with: @close_date.strftime("%d-%m-%Y")
  click_on("modal-change-close-date")
end

Then /^the proposal close date should be updated$/ do
  find('#closing-info').should have_content("Closing in 5 days")
end

Then /^I should not see a link to edit the close date$/ do
  page.should_not have_css("change-close-date")
end

Then /^I should see the edit close date modal$/ do
  find("#edit-close-date")
end

Then(/^I should see "(.*?)" in the discussion feed$/) do |arg1|
  find('#activity-feed').should have_content(arg1)
end

