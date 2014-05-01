require 'spec_helper'
describe AcceptInvitation do
  let(:group) { FactoryGirl.create(:group) }
  let(:invitation) { FactoryGirl.create(:invitation, invitable: group) }
  let(:user) { FactoryGirl.create(:user) }

  context 'and_grant_access!' do
    before do
      AcceptInvitation.and_grant_access!(invitation, user)
    end

    it 'sets accepted_by to the user' do
      invitation.accepted_by.should == user
    end

    it 'sets accepted_at' do
      invitation.accepted_at.should be_present
    end

    context 'to_be_admin' do
      let(:invitation) { FactoryGirl.create(:invitation,
                                            to_be_admin: true,
                                            invitable: group) }

      it 'makes the user a group admin' do
        group.admins.should include user
      end
    end

    context 'not to_be_admin' do
      it 'adds the user to the group as a member' do
        group.members.should include user
      end
    end

    it 'notifies the invitor of acceptance' do
      Event.last.kind.should == 'invitation_accepted'
    end
  end
end
