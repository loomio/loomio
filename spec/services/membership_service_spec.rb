require 'rails_helper'

describe MembershipService do
  let(:group) { create :formal_group, discussion_privacy_options: :public_only, is_visible_to_public: true, membership_granted_upon: :request }
  let(:user)  { create :user }
  let(:admin) { create :user }
  let(:invitation) { create :invitation, group: group, recipient_email: user.email }

  before { group.add_admin! admin }

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
      expect(invitation.is_pending?).to eq true
      MembershipService.join_group(group: group, actor: user)
      expect(invitation.reload.is_pending?).to eq false
    end
  end

  describe 'add_users_to_group' do
    it 'marks pending invitations as used' do
      invitation
      expect(invitation.is_pending?).to eq true
      MembershipService.add_users_to_group(users: [user], group: group, inviter: admin)
      expect(invitation.reload.is_pending?).to eq false
    end
  end

end
