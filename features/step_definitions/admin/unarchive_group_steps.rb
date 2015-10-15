Given(/^there is a user in an archived group$/) do
  @user = FactoryGirl.create :user
  @user.save!
  @group = FactoryGirl.create :group, discussion_privacy_options: 'public_or_private'
  @membership = @group.add_member! @user
  @discussion = FactoryGirl.create :discussion, group: @group, private: false
  @subgroup = FactoryGirl.create :group, parent: @group
  @group.archive!
end

When(/^their group is unarchived$/) do
  @group.unarchive!
end

When(/^they sign\-in$/) do
  visit new_user_session_path
  fill_in 'Email', with: @user.email
  fill_in 'Password', with: @user.password
  click_on 'sign-in-btn'
end

Then(/^they should be able to view their group page$/) do
  visit group_path(@group)
  page.should have_content(@group.name)
end

Then(/^they should be able to view group discussions$/) do
  page.should have_content(@discussion.title)
end

Then(/^any subgroups should be unarchived$/) do
  page.should have_content(@subgroup.name)
end
