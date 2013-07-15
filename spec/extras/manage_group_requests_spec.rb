require 'spec_helper'

describe 'ManageMembershipRequests' do

  describe '#approve!(membership_request, approved_by: user)' do

    context 'membership request from visitor' do
      let(:membership_request) { stub(:membership_request, email: requestor_email, group: group, requestor: nil, from_a_visitor?: true) }
      let(:requestor_email) { 'bob@jones.com' }
      let(:coordinator) { stub(:coordinator, email: 'coord@nator.com') }
      let(:group) { stub(:group) }
      let(:mailer) { stub(:mailer, :deliver => nil) }
      let(:invitation) { stub(:invitation) }
      before do
        CreateInvitation.stub(:after_membership_request_approval).and_return(invitation)
        InvitePeopleMailer.stub(:after_membership_request_approval).and_return(mailer)
        membership_request.stub(:approve!).with(coordinator)
      end

      after do
        ManageMembershipRequests.approve!(membership_request, approved_by: coordinator)
      end

      it 'approves the membership request' do
        membership_request.should_receive('approve!').with(coordinator)
      end

      it 'creates invitation to join the group' do
        args = {recipient_email: requestor_email, inviter: coordinator, group: group}
        CreateInvitation.should_receive(:after_membership_request_approval).with(args)
      end

      it 'emails invitation to the user' do
        InvitePeopleMailer.should_receive(:after_membership_request_approval).with(invitation, coordinator.email, '')
      end
    end

    context 'membership request from signed-in user' do
      let(:membership_request) { stub(:membership_request, requestor: requestor, group: group, from_a_visitor?: false) }
      let(:coordinator) { stub(:coordinator, email: 'coord@nator.com') }
      let(:requestor) { stub(:requestor) }
      let(:group) { stub(:group, :add_member! => 'new_membership') }
      before do
        Events::UserAddedToGroup.stub(:publish!)
        membership_request.stub(:approve!).with(coordinator)
      end
      after do
        ManageMembershipRequests.approve!(membership_request, approved_by: coordinator)
      end

      it 'approves the membership request' do
        membership_request.should_receive('approve!').with(coordinator)
      end

      it 'adds the user to the group' do
        group.should_receive(:add_member!).with(requestor)
      end

      it 'creates a membership request approved notification' do
        Events::UserAddedToGroup.should_receive(:publish!).with('new_membership')
      end
    end
  end

  describe '#ignore'

  describe '#cancel'
end
