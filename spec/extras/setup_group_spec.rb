require 'spec_helper'

describe SetupGroup do
  before do
    @approver = FactoryGirl.create(:user)
    @group_request = FactoryGirl.create(:group_request)
    @setup_group = SetupGroup.new(@group_request)
    @group_request.verify!
  end

  describe 'approve_group_request!' do
    before do
      @group = @setup_group.approve_group_request!(approved_by: @approver)
    end

    it 'does not set the group creator' do
      @group.creator.should be_nil
    end

    it 'creates the group' do
      @group.should be_persisted
    end

    it 'copies attributes from group_request' do
      %w[name country_name cannot_contribute max_size sectors other_sector].each do |attr|
        @group.send(attr).should == @group_request.send(attr)
      end
    end

    it 'aprroves the group request' do
      @group_request.should be_approved
    end

    it 'assigns the group_request to the group' do
      @group.group_request.should == @group_request
    end

    it 'records who approved the group request', focus: true do
      @group_request.approved_by.should == @approver
    end
  end

  describe 'send_group_admin_invitiation_email' do
    let(:mailer_stub){ stub(:mailer_stub, :deliver => true)}
    let(:message_body) { 'yo i am the message body {link_to_replace}'}

    before do
      @group = @setup_group.approve_group_request!(approved_by: @approver)
    end

    after do
      @setup_group.send_invitation_to_start_group!(message_body)
    end

    it 'emails the group admin' do
      StartGroupMailer.should_receive(:invite_admin_to_start_group).
      with(@group_request, message_body).and_return(mailer_stub)
    end
  end
end