When /^I complete an invitation$/ do
  visit '/groups/' + Group.last.id.to_s
  fill_in 'user_email', with: 'new_group_member@example.com'
  click_on 'invite'
end

Then /^a member is added to the group$/ do
  Membership.where(:group_id => Group.last.id, :user_id => User.last.id).size > 0
end

Given /^there exists a user to add to the group$/ do
  User.create(:email => "new_group_member@example.com", :password =>"password", :name => "New Member")
end

When /^no such user is already in the group$/ do
  Membership.where(:group_id => Group.last.id, :user_id => User.last.id).size == 0
end

Given /^there is a user in the group$/ do
  visit '/groups/' + Group.last.id.to_s
  fill_in 'user_email', with: 'new_group_member@example.com'
  click_on 'invite'
end

Then /^a member is not added to the group$/ do
  page.should have_content('new_group_member@example.com is already in the group.')
end