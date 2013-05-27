require 'spec_helper'

describe 'CreateInvitation' do
  
  context 'to_start_a_group' do
    let(:group) {FactoryGirl.create(:group)}
    let(:admin_user) {FactoryGirl.create(:admin_user)}

    before do
      @invitation = CreateInvitation.to_start_group(
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
      @invitation.group.should == group
    end

    it 'is to join as an admin' do
      @invitation.to_be_admin?.should be_true
    end
  end

  context 'to_join_group' do
    let(:group) {FactoryGirl.create(:group)}
    let(:admin_user) {FactoryGirl.create(:admin_user)}


    before do
      @invitation = CreateInvitation.to_join_group(
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
      @invitation.group.should == group
    end

    it 'is to join as an admin' do
      @invitation.to_be_admin?.should be_false
    end
  end
end
