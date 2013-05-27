require 'spec_helper'

describe Invitation do
  describe 'create' do
    let(:admin_user){FactoryGirl.create(:admin_user)}
    let(:group){FactoryGirl.create(:group)}
    before do
      @invitation = Invitation.create(recipient_email: 'test@example.org',
                                      intent: 'join_group',
                                      inviter: admin_user,
                                      group: group)
    end

    it 'gives the invitation a token' do
      @invitation.token.should be_present
    end
  end
end
