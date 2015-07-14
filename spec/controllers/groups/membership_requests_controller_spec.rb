require 'rails_helper'

describe Groups::MembershipRequestsController do

  describe '#cancel' do
    let(:requestor) { create(:user) }
    let(:group) { create :group}
    let(:membership_request) { create :membership_request, group: group, requestor_id: requestor.id }

    before do
      MembershipRequest.stub(:find).with(membership_request.id.to_s).and_return(membership_request)
      Group.stub(:find).and_return(group)
      membership_request.stub(:destroy)
      controller.stub(:current_user).and_return requestor
      sign_in requestor
    end

    context "a user has permission to cancel membership request" do
      before { controller.stub(:authorize!).with(:cancel, membership_request).and_return(true) }
      it "destroys the membership request" do
        membership_request.should_receive(:destroy)
        post :cancel, id: membership_request.id
      end

      it "redirects them to group page with success flash" do
        post :cancel, id: membership_request.id
        expect(flash[:success]).to match(/Membership request canceled/i)
      end
    end

    context "a user doesn't have permission to cancel membership request" do
      before { membership_request.stub(:requestor_id).and_return(requestor.id+1) }
      it "doesn't destroy the membership request" do
        membership_request.should_not_receive(:destroy)
        post :cancel, id: membership_request.id
      end
    end
  end
end
