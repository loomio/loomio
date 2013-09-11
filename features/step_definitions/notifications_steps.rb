Given(/^I have a proposal which has expired$/) do
  @motion = FactoryGirl.create :motion, author: @user
  @motion.close_at_date = Date.parse((Time.zone.now - 10.days).to_s)
  @motion.save
end

When(/^I click the notifications dropdown$/) do
  find("#notifications-toggle").click
end

Then(/^I should see that the motion expired$/) do
  find("#notifications-container").should have_content(I18n.t('notifications.motion_closed.by_expiry') + ": " + @motion.name)
end

Given(/^someone has closed a proposal in a group I belong to$/) do
  @motion = FactoryGirl.create :motion
  @group = @motion.group
  @closer = FactoryGirl.create :user
  @group.add_member!(@closer)
  @group.add_member!(@user)
  @motion.close!(@closer)
end

Then(/^I should see that someone closed the motion$/) do
  find("#notifications-container").should have_content(@closer.name + " " + I18n.t('notifications.motion_closed.by_user'))
end

