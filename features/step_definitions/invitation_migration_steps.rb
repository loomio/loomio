Given(/^there is a user account created by devise invitable$/) do
  @group = FactoryGirl.create :group

  @inviter = FactoryGirl.create :user

  @invitation_token = "NSFBhpSxuqPrvpv2MLe7"

  @invitee = FactoryGirl.create :user
  @group.add_member! @invitee
  @invitee.email = "dog@bones.com"
  @invitee.name = "dog@bones.com"
  @invitee.invitation_token = @invitation_token
  @invitee.invitation_sent_at = "2013-05-23 00:45:36"
  @invitee.invitation_accepted_at = nil
  @invitee.invited_by_id = @inviter.id
  @invitee.invited_by_type = "User"
  @invitee.save!
end

When(/^I migrate the devise invited users to invitations$/) do
  MigrateInvitations.now
end

Then(/^there should be an invitation with the same token, group and inviter$/) do
  @invitation = Invitation.find_by_token @invitation_token
  @invitation.inviter.should == @inviter
  @invitation.group.should == @group
  @invitation.token.should == @invitation_token
end

When(/^I load a devise invitation link$/) do
  @inviter = FactoryGirl.create :user
  @group = FactoryGirl.create :group

  @invitation = CreateInvitation.to_join_group(recipient_email: 'dog@cats.com',
                                              inviter: @inviter,
                                              group: @group)
  visit "/users/invitation/accept?invitation_token=#{@invitation.token}"
end

Then(/^I should be redirected to the appropriate invitation path$/) do
  current_path.should == invitation_path(@invitation)
end

When(/^I destroy the old invited users$/) do
  @invitee = FactoryGirl.create :user
  @invitee.email = "dog@bones.com"
  @invitee.name = "dog@bones.com"
  @invitee.invitation_token = "partyrock"
  @invitee.invitation_sent_at = "2013-05-23 00:45:36"
  @invitee.invitation_accepted_at = nil
  @invitee.save!

  MigrateInvitations.destroy_old_users
end

Then(/^the users should be destroyed$/) do
  expect { @invitee.reload }.to raise_error ActiveRecord::RecordNotFound
end
