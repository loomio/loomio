Given(/^there is an open proposal in the group$/) do
  @discussion = FactoryGirl.create(:discussion, group: @group)
  @motion = Motion.create(discussion: @discussion,
                          name: 'We doo it',
                          description: 'we dooo it',
                          closing_at: 5.days.from_now,
                          author: @user)
end

When(/^I update the proposal$/) do
  visit discussion_path @discussion
  find('.cuke-edit-motion').click
  fill_in 'motion_name', with: 'updated title'
  fill_in 'motion_description', with: 'updated description'
  fill_in 'motion_closing_at', with: 5.days.from_now.to_datetime.strftime('%Y-%m-%d %l:%M %p').gsub('  ', ' ')
  click_on 'Update proposal'
end

Then(/^the proposal should be updated$/) do
  visit discussion_path @discussion
  page.should have_content 'updated title'
  page.should have_content 'updated description'
end

When(/^I close the proposal via the edit form$/) do
  visit discussion_path @discussion
  find('.cuke-edit-motion').click
  click_on 'Close proposal'
end
