require 'rails_helper'
describe InvitationService do
  let(:group) { FactoryGirl.create(:group) }
  let(:invitation) { FactoryGirl.create(:invitation, invitable: group) }
  let(:user) { FactoryGirl.create(:user) }

  describe 'redeem' do
    before do
      InvitationService.redeem(invitation, user)
    end

    context 'single use' do

      it 'sets accepted_at' do
        invitation.accepted_at.should be_present
      end
    end

    context 'multiple use' do
      let(:invitation) { FactoryGirl.create(:invitation, invitable: group, single_use: false) }

      it 'does not mark as accepted' do
        expect(invitation.accepted_at).to eq nil
      end
    end

    context 'to_be_admin' do
      let(:invitation) { FactoryGirl.create(:invitation,
                                            to_be_admin: true,
                                            invitable: group) }

      it 'makes the user a group admin' do
        group.admins.reload.should include user
      end
    end

    context 'not to_be_admin' do
      it 'adds the user to the group as a member' do
        group.members.reload.should include user
      end
    end

    it 'notifies the invitor of acceptance' do
      expect(Event.last.kind).to eq 'invitation_accepted'
    end
  end

  describe '#resend_ignored' do

    it 'resends invitations after a specified period' do
      invitation.update_attributes(created_at: 30.hours.ago, send_count: 1)
      expect { InvitationService.resend_ignored(send_count: 1, since: 1.day.ago) }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'does not resend accepted invitations' do
      invitation.update_attributes(created_at: 30.hours.ago, send_count: 1, accepted_at: Time.now)
      expect { InvitationService.resend_ignored(send_count: 1, since: 1.day.ago) }.to_not change { ActionMailer::Base.deliveries.count }
    end

    it 'does not resend cancelled invitations' do
      invitation.update_attributes(created_at: 30.hours.ago, send_count: 1, cancelled_at: Time.now)
      expect { InvitationService.resend_ignored(send_count: 1, since: 1.day.ago) }.to_not change { ActionMailer::Base.deliveries.count }
    end

    it 'does not resend invitations outside specified period' do
      invitation.update_attributes(created_at: 10.hours.ago, send_count: 1)
      expect { InvitationService.resend_ignored(send_count: 1, since: 1.day.ago) }.to_not change { ActionMailer::Base.deliveries.count }
    end

    it 'does not send invitations that have no send count' do
      invitation.update_attributes(created_at: 30.hours.ago)
      expect { InvitationService.resend_ignored(send_count: 1, since: 1.day.ago) }.to_not change { ActionMailer::Base.deliveries.count }
    end

    it 'increments the send count when invitation successfully resent' do
      invitation.update_attributes(created_at: 30.hours.ago, send_count: 1)
      InvitationService.resend_ignored(send_count: 1, since: 1.day.ago)
      expect(Invitation.last.send_count).to eq 2
    end
  end

  describe 'redeem_with_identity' do
    let(:identity) { create :slack_identity }
    it 'associates the identity with the user' do
      InvitationService.redeem(invitation, user, identity)
      expect(identity.reload.user).to eq user
      expect(user.identities).to include identity
      expect(user.groups).to include group
    end
  end
end
