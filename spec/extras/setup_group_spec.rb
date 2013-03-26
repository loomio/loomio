require 'spec_helper'

describe SetupGroup do
  describe 'accept_group_request!' do
    before do
      setup_group = SetupGroup.new
      @group = setup_group.approve_group_request!(@group_request)
    end

    it 'does not set the group creator' do
      @group.creator.should be_nil
    end

    it 'creates the group' do
      @group.should be_persisted
    end

    it 'aprroves the group request' do
      @group_request.should be_approved
    end
  end

  describe 'send_group_admin_invitiation_email' do
    it 'emails the group admin'
    it 'converts the link placeholder into a url'
  end
end