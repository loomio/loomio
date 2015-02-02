Given(/^there is a user with a deactivated account$/) do
  @user = FactoryGirl.create(:user, name: "Marge", email: "marge@large.org")
  @user.save!
  @group = FactoryGirl.create :group
  @membership = FactoryGirl.create(:membership, user: @user, group: @group)
  @user.deactivate!
end

When(/^their account is reactivated$/) do
  @user.reactivate!
end

Then(/^the user's deactivated_at attribute should be set to nil$/) do
  @user.deactivated_at.should be_nil
end

Then(/^the user's memberships should be restored$/) do
  @membership.reload
  @membership.archived_at.should be_nil
end

Then(/^they should see the dashboard$/) do
  page.should have_content('Signed in successfully')
end

Then(/^they should be able to view their groups$/) do
  visit group_path(@group)
  page.should have_content(@group.name)
end
