require 'spec_helper'

describe Invitation do
  let(:admin_user){FactoryGirl.create(:admin_user)}
  let(:group){FactoryGirl.create(:group)}

  before do
    @invitation = Invitation.create(recipient_email: 'test@example.org',
                                    recipient_name: 'Joinky',
                                    intent: 'join_group',
                                    inviter: admin_user,
                                    invitable: group)
  end

  describe 'create' do
    it 'gives the invitation a token' do
      @invitation.token.should be_present
    end
  end

  describe 'accepted?' do
    subject do
      @invitation.accepted?
    end

    context 'accepted_by present' do
      before do
        @invitation.accepted_by = FactoryGirl.create(:user)
      end
      it {should be_true}
    end

    context 'accepted_by blank' do
      before do
        @invitation.accepted_by = nil
      end
      it {should be_false}
    end
  end

  describe 'cancel!' do
    before do
      @invitation.cancel!(canceller: @admin_user)
    end

    it 'sets attribute cancelled_at' do
      @invitation.cancelled_at.should be_present
    end

    it 'sets attribute canceller' do
      @invitation.canceller.should == @admin_user
    end

    it 'should be cancelled' do
      @invitation.should be_cancelled
    end
  end

  context 'to_start_a_group' do

    before do
      @invitation = InvitationService.create_invite_to_start_group(
        inviter: admin_user,
        recipient_email: 'jon@lemmon.com',
        group: group)
    end

    it 'has a unique token' do
      @invitation.token.length.should > 10
    end

    it 'specifies the recpient email' do
      @invitation.recipient_email.should == 'jon@lemmon.com'
    end

    it 'specifies the group' do
      @invitation.invitable.should == group
    end

    it 'is to join as an admin' do
      @invitation.to_be_admin?.should be_true
    end
  end

  context 'to_join_group' do

    before do
      @invitation = InvitationService.create_invite_to_join_group(
        inviter: admin_user,
        recipient_email: 'jon@lemmon.com',
        group: group)
    end
    it 'has a unique token' do
      @invitation.token.length.should > 10
    end

    it 'specifies the recpient email' do
      @invitation.recipient_email.should == 'jon@lemmon.com'
    end

    it 'specifies the group' do
      @invitation.invitable.should == group
    end

    it 'is to join as an admin' do
      @invitation.to_be_admin?.should be_false
    end
  end
end
