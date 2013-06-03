require 'spec_helper'

describe Invitation do
  let(:admin_user){FactoryGirl.create(:admin_user)}
  let(:group){FactoryGirl.create(:group)}

  before do
    @invitation = Invitation.create(recipient_email: 'test@example.org',
                                    intent: 'join_group',
                                    inviter: admin_user,
                                    group: group)
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
end
