Given /^I am an admin of a group with a discussion$/ do
  @group = FactoryGirl.create :group
  @discussion = FactoryGirl.create :discussion, :group => @group
  @group.add_admin! @user
end

When /^I click the 'change close date' button$/ do
  click_on 'change-close-date'
end

When /^I select the new close date$/ do
  pending
  @close_date = 5.days.from_now
  fill_in "input_date", :with  => @close_date
  click_on("change-close-date")
end

Then /^The proposal close date should be updated$/ do
  pending
  find('#closing-info').should have_content("Closing in 5 days")
end

Then /^I should not see a link to edit the close date$/ do
  page.should_not have_css("change-close-date")
end