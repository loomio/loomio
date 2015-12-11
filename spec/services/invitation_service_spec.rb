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
end
