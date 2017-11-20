require 'rails_helper'

describe Invitation do
  let(:admin_user){FactoryGirl.create(:admin_user)}
  let(:group){FactoryGirl.create(:formal_group)}

  before do
    @invitation = Invitation.create(recipient_email: 'test@example.org',
                                    recipient_name: 'Joinky',
                                    intent: 'join_group',
                                    inviter: admin_user,
                                    group: group)
  end

  describe 'recipient_email' do
    it 'is invalid when using a forbidden email' do
      expect(build(:invitation, recipient_email: User::FORBIDDEN_EMAIL_ADDRESSES.first)).to_not be_valid
    end
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

    context 'accepted_at present' do
      before do
        @invitation.accepted_at = Time.now
      end
      it {should be true}
    end

    context 'accepted_at blank' do
      before do
        @invitation.accepted_at = nil
      end
      it {should be false}
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
      expect(@invitation.canceller).to eq @admin_user
    end

    it 'should be cancelled' do
      @invitation.should be_cancelled
    end
  end

  context 'to_join_group' do

    before do
      @invitation = create(:invitation, inviter: admin_user, recipient_email: 'jon@lemmon.com', group: group, intent: :join_group)
    end
    it 'has a unique token' do
      @invitation.token.length.should > 10
    end

    it 'specifies the recpient email' do
      expect(@invitation.recipient_email).to eq 'jon@lemmon.com'
    end

    it 'specifies the group' do
      expect(@invitation.group).to eq group
    end

    it 'is to join as an admin' do
      @invitation.to_be_admin?.should be false
    end
  end
end
