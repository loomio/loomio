Given(/^there is a user in a group$/) do
  @user = FactoryGirl.create(:user, name: "Marge", email: "marge@large.org", email_missed_yesterday: true)
  @user.save!
  @group = FactoryGirl.create :group
  @membership = @group.add_member! @user
end

When(/^their account is deactivated$/) do
  @user.deactivate!
end

Then(/^the user's deactivated_at attribute should be set$/) do
  User.where("deactivated_at IS NOT NULL").should exist
end

And(/^the user's memberships should be archived$/) do
  @membership.reload
  @membership.archived_at.should_not be_nil
end

When (/^they attempt to sign in$/) do
  visit new_user_session_path
  fill_in 'Email', with: @user.email
  fill_in 'Password', with: 'complex_password'
  click_on 'sign-in-btn'
end

Then (/^they should be told their account is inactive$/) do
  page.should have_content'This account has been deactivated.'
end
