
When(/^I click the contribute icon$/) do
  find('li#contribute').click
end

Then(/^I should see the contribution page$/) do
  page.should have_css('body.contributions.index')
end

Given(/^I am not a member of a paying group$/) do
  @group = FactoryGirl.create :group, paying_subscription: false
  @group.save!
  @group.add_member! @user
end

Given(/^I am a member of a paying group$/) do
  @group = FactoryGirl.create :group, paying_subscription: true
  @group.save!
  @group.add_member! @user
end

When(/^I visit the pay what you can page$/) do
  visit contributions_path
end

Then(/^I should see a confirmation page thanking me for my contribution$/) do
  pending # can't be checked because of swipe callback
end

Then(/^I do not see the pay what you can icon in the navbar$/) do
  page.should_not have_css("#contribute")
end

Then(/^I be should be redirected to the sign in page$/) do
  page.should have_css('body.sessions.new')
end
