When /^I complete an invitation$/ do
  fill_in 'user_email', with: 'new_group_member@example.com'
end

When /^no such member already exists$/ do
  User.where(:email => 'new_group_member@example.com') == 0
end

Then /^a member is added to the group$/ do
  Membership.where(:group_id => Group.last.id, :user_id => User.last.id).size > 0
end