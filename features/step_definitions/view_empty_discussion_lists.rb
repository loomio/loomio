include ActionView::Helpers::SanitizeHelper
When(/^I view an empty open group$/) do
  @group = FactoryGirl.create(:group,
                              membership_granted_upon: 'request',
                              discussion_privacy_options: 'public_only',
                              visible_to: 'public')
  visit group_path @group
end

When(/^I view an empty 'join by approval' group$/) do
  @group = FactoryGirl.create(:group,
                              membership_granted_upon: 'approval',
                              discussion_privacy_options: 'public_or_private',
                              visible_to: 'public')
  visit group_path @group
end

When(/^I view an empty 'join by member invitation' group$/) do
  @group = FactoryGirl.create(:group,
                              discussion_privacy_options: 'public_or_private',
                              membership_granted_upon: 'invitation',
                              members_can_add_members: true,
                              visible_to: 'public')
  visit group_path @group
end

When(/^I view an empty 'join by admin invitation' group$/) do
  @group = FactoryGirl.create(:group,
                              discussion_privacy_options: 'public_or_private',
                              membership_granted_upon: 'invitation',
                              members_can_add_members: false,
                              visible_to: 'public')
  visit group_path @group
end

Then(/^I see there are no discussions in the group$/) do
  page.should have_content I18n.t(:'discussion_list.empty.no_discussions_in_group')
end

When(/^I view an empty 'join by invitation' group$/) do
  @group = FactoryGirl.create(:group,
                              membership_granted_upon: 'invitation',
                              is_visible_to_public: true)
  visit group_path @group
end

Then(/^I see a message telling them to log in if they are a member$/) do
  page.should have_content I18n.t(:'discussion_list.empty.not_signed_in_html', href: new_user_session_path)
end

Given(/^I am a member of an empty group$/) do
  @group = FactoryGirl.create(:group)
  @group.add_member! @user
end

When(/^I visit the group$/) do
  visit group_path @group
end

Then(/^I see message the group has no public discussions$/) do
  page.should have_content I18n.t(:'discussion_list.empty.no_public_discussions')
end

Then(/^I see message to request membership$/) do
  page.should have_content strip_links I18n.t(:'discussion_list.empty.request_membership_html', href: new_group_membership_request_path(@group.id))
end

Then(/^I see message to log in if I'm a member$/) do
  page.should have_content strip_links I18n.t(:'discussion_list.empty.log_in_html', href: new_user_session_path)
end


Then(/^I see message that the group is invite by member only$/) do
  page.should have_content I18n.t(:'discussion_list.empty.membership_is_invitation_only')
end

Then(/^I see message that the group is invite by admin only$/) do
  page.should have_content I18n.t(:'discussion_list.empty.membership_is_invitation_by_admin_only')
end

