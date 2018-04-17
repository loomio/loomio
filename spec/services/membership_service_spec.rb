require 'rails_helper'

describe MembershipService do
  let(:group) { create :formal_group, discussion_privacy_options: :public_only, is_visible_to_public: true, membership_granted_upon: :request }
  let(:user)  { create :user }
  let(:admin) { create :user }
  let(:unverified_user) { create :user, email_verified: false }
  let(:membership) { create :membership, group: group, user: unverified_user }

  before { group.add_admin! admin }

  describe 'redeem' do
    before do
      MembershipService.redeem(membership: membership, actor: user)
    end

    it 'sets accepted_at' do
      membership.accepted_at.should be_present
    end

    it 'notifies the invitor of acceptance' do
      expect(Event.last.kind).to eq 'invitation_accepted'
    end
  end

  describe '#resend_ignored' do
    it 'resends invitations after a specified period' do
      membership.update_attributes(created_at: 30.hours.ago, send_count: 1)
      expect { InvitationService.resend_ignored(send_count: 1, since: 1.day.ago) }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'does not resend accepted invitations' do
      membership.update_attributes(created_at: 30.hours.ago, send_count: 1, accepted_at: Time.now)
      expect { InvitationService.resend_ignored(send_count: 1, since: 1.day.ago) }.to_not change { ActionMailer::Base.deliveries.count }
    end

    it 'does not resend cancelled invitations' do
      membership.update_attributes(created_at: 30.hours.ago, send_count: 1, cancelled_at: Time.now)
      expect { InvitationService.resend_ignored(send_count: 1, since: 1.day.ago) }.to_not change { ActionMailer::Base.deliveries.count }
    end

    it 'does not resend invitations outside specified period' do
      membership.update_attributes(created_at: 10.hours.ago, send_count: 1)
      expect { InvitationService.resend_ignored(send_count: 1, since: 1.day.ago) }.to_not change { ActionMailer::Base.deliveries.count }
    end

    it 'does not send invitations that have no send count' do
      membership.update_attributes(created_at: 30.hours.ago)
      expect { InvitationService.resend_ignored(send_count: 1, since: 1.day.ago) }.to_not change { ActionMailer::Base.deliveries.count }
    end

    it 'increments the send count when invitation successfully resent' do
      membership.update_attributes(created_at: 30.hours.ago, send_count: 1)
      InvitationService.resend_ignored(send_count: 1, since: 1.day.ago)
      expect(Invitation.last.send_count).to eq 2
    end
  end



  describe 'join_group' do
    it 'adds the user as creator if the group has no creator' do
      group.update(creator: nil)
      MembershipService.join_group(group: group, actor: user)
      expect(group.reload.creator).to eq user
    end

    it 'does not eliminate the former creator' do
      group.update(creator: create(:user))
      MembershipService.join_group(group: group, actor: user)
      expect(group.reload.creator).to_not eq user
    end

    it 'marks pending invitations as used' do
      invitation
      expect(membership.is_pending?).to eq true
      MembershipService.join_group(group: group, actor: user)
      expect(membership.reload.is_pending?).to eq false
    end
  end

  describe 'add_users_to_group' do
    it 'marks pending invitations as used' do
      invitation
      expect(membership.is_pending?).to eq true
      MembershipService.add_users_to_group(users: [user], group: group, inviter: admin)
      expect(membership.reload.is_pending?).to eq false
    end
  end

end
