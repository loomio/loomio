require "#{File.dirname(__FILE__)}/../../lib/invites_users_to_group"

class Invitation
end

class GroupInvitationMailer
end

describe InvitesUsersToGroup do
  let(:group) {stub(:group)}
  let(:inviter) {stub(:inviter)}
  let(:email) {stub(:email).as_null_object}

  before :each do
    GroupInvitationMailer.stub(:invite_member).and_return(email)
    Invitation.stub(:create!)
  end

  it 'creates an invitation for each recipient' do

    recipient_emails = ['jon@lemmon.com', 'rob@guthrie.com']

    Invitation.should_receive(:create!).with :recipient_email => 'jon@lemmon.com',
                                              :group => group,
                                              :access_level => 'member', 
                                              :inviter => inviter

    Invitation.should_receive(:create!).with :recipient_email => 'rob@guthrie.com',
                                            :group => group,
                                            :access_level => 'member', 
                                            :inviter => inviter

    InvitesUsersToGroup.invite!(:recipient_emails => recipient_emails,
                                :as => 'members',
                                :inviter => inviter,
                                :access_level => 'member',
                                :group => group)
  end

  it 'sends an email with the invitation token' do
    
    email.should_receive(:deliver)
    GroupInvitationMailer.should_receive(:invite_member).
      with(:recipient_email => 'rob@guthrie.com',
           :group => group,
           :inviter => inviter).and_return(email)

    InvitesUsersToGroup.invite!(:recipient_emails => ['rob@guthrie.com'],
                                :as => 'members',
                                :inviter => inviter,
                                :access_level => 'member',
                                :group => group)
  end
end
