Given /^I am an admin of a group with a discussion$/ do
  @group = FactoryGirl.create :group
  @discussion = FactoryGirl.create :discussion, :group => @group
  @group.add_admin! @user
end

Given /^my time zone setting has been set$/ do
  @user.time_zone = "Bokota"
  @user.save!
end

When /^I click the 'change close date' button$/ do
  click_on 'change-close-date'
end

When /^I select the new close date$/ do
  pending
  @close_date = 5.days.from_now
  fill_in "close_date_at", :with  => @close_date
  click_on("change-close-date")
end

Then /^The proposal close date should be updated$/ do
  pending
  find('#closing-info').should have_content("Closing in 5 days")
end

Then /^I should not see a link to edit the close date$/ do
  page.should_not have_css("change-close-date")
end

Then /^I should see the edit close date modal$/ do
  find("#edit-close-date")
end

Then /^the time zone should match my time zone setting$/ do
  @user.reload
  # find(".motion-close-at-time-zone").find("option[text()= '(GMT-05:00) Bakota')#.text.should have_content(@user.time_zone)
  page.should have_xpath "//select[@id = 'motion_close_at_time_zone']/option[@value = '']"
end

Then /^The proposal close date should change$/ do
  pending # express the regexp above with the code you wish you had
end