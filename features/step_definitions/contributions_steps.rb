# When(/^I click the contribute icon$/) do
#   find('li#contribute').click
# end

# Then(/^I should see the contribution page$/) do
#   page.should have_css('body.contributions.index')
# end

# Given(/^I am a member of a pwyc group$/) do
#   @group = FactoryGirl.create :group, payment_plan: 'pwyc'
#   @group.save!
#   @group.add_member! @user
# end

# Given(/^I am a member of a group with an undetermined payment plan$/) do
#   @group = FactoryGirl.create :group, payment_plan: 'undetermined'
#   @group.save!
#   @group.add_member! @user
# end

# Given(/^I am a member of a manual subscription group$/) do
#   @group = FactoryGirl.create :group, payment_plan: 'manual_subscription'
#   @group.save!
#   @group.add_member! @user
# end

# When(/^I visit the pay what you can page$/) do
#   visit contributions_path
# end

# Then(/^I should see a confirmation page thanking me for my contribution$/) do
#   pending # can't be checked because of swipe callback
# end

# Then(/^I should not see the pay what you can icon in the navbar$/) do
#   page.should_not have_css("#contribute")
# end

# Then(/^I be should be redirected to the sign in page$/) do
#   page.should have_css('body.sessions.new')
# end
