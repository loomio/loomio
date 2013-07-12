require 'spec_helper'

describe Groups::ManageMembershipRequestsController do
  describe "#index"

  describe "#approve" do
    let(:group) { mock_model Group }
    let(:membership_request) { mock_model MembershipRequest, group: group, name: "James Roland", response: nil, from_a_visitor?: nil }
    let(:coordinator) { create(:user) }
    let(:requestor) { mock_model User }

    before do
      controller.stub(:set_locale)
      controller.stub(:load_announcements)
      controller.stub(:current_user).and_return coordinator
      MembershipRequest.stub(:find).and_return(membership_request)
      Group.stub(:find).with(group.id.to_s).and_return(group)
      ManageMembershipRequests.stub(:approve!)
      sign_in coordinator
    end

    context "user doesn't have permission to approve membership request" do
      it 'redirects to root path with flash error' do
        post :approve, id: membership_request.id
        response.should redirect_to root_path
      end
      it 'does not approve the membership request' do
        membership_request.should_not_receive(:approve!)
        post :approve, id: membership_request.id
      end
    end

    context "user has permission to approve membership request" do
      before { controller.stub(:authorize!).and_return(true) }

      context 'request from a visitor' do
        before {
          membership_request.stub(:requestor)
          membership_request.stub(:from_a_visitor?).and_return(true)
        }
        it 'marks the request as approved' do
          ManageMembershipRequests.should_receive(:approve!)
          post :approve, id: membership_request.id
        end
        it 'redirects to group with flash message' do
          post :approve, id: membership_request.id
          response.should redirect_to group_membership_requests_path(group)
          flash[:success].should =~ /membership approved/i
        end
      end

      context 'request from a user' do
        before {
          membership_request.stub(:requestor).and_return(requestor)
          membership_request.stub(:from_a_visitor?).and_return(false)
        }
        it 'marks the request as approved' do
          ManageMembershipRequests.should_receive(:approve!)
          post :approve, id: membership_request.id
        end
        it 'redirects to group with flash message' do
          post :approve, id: membership_request.id
          response.should redirect_to group_membership_requests_path(group)
          flash[:success].should =~ /membership approved/i
        end
      end

      context "membership request has already been approved" do
        before { membership_request.stub(:response).and_return('approved') }
        it "redirects to group membership requests index with flash message" do
          post :approve, id: membership_request.id
          flash[:warning].should =~ /membership request has already been approved/i
          response.should redirect_to group_membership_requests_path(group)
        end
      end
      context "membership request has been ignored" do
        before { membership_request.stub(:response).and_return('ignored') }
        it "redirects to membership requests index with flash message" do
          post :approve, id: membership_request.id
          flash[:warning].should =~ /membership request has already been ignored/i
          response.should redirect_to group_membership_requests_path(group)
        end
      end
      context "membership request has been cancelled" do
        it "redirects to group with flash message"
      end
    end
  end

  describe "ignore" do
    let(:group) { mock_model Group }
    let(:membership_request) { mock_model MembershipRequest, group: group, name: "James Roland", response: nil }
    let(:coordinator) { create(:user) }

    before do
      controller.stub(:set_locale)
      controller.stub(:load_announcements)
      controller.stub(:current_user).and_return coordinator
      MembershipRequest.stub(:find).and_return(membership_request)
      Group.stub(:find).with(group.id.to_s).and_return(group)
      ManageMembershipRequests.stub(:ignore!)
      sign_in coordinator
    end

    context "user has permission to ignore request" do
      before { controller.stub(:authorize!).and_return(true) }
      it "marks the request as 'ignored'" do
        ManageMembershipRequests.should_receive(:ignore!)
        post :ignore, id: membership_request.id
      end

      it "redirects to the group membership index with a flash message" do
        post :ignore, id: membership_request.id
        response.should redirect_to group_membership_requests_path(group)
        flash[:success].should =~ /ignored/i
      end

      context "request has already been ignored" do
        before { membership_request.stub(:response).and_return('ignored')  }
        it "redirects to the group index with a flash message" do
          post :ignore, id: membership_request.id
          response.should redirect_to group_membership_requests_path(group)
          flash[:warning].should =~ /has already been ignored/i
        end
      end
    end

    context "user doesn't have permission to ignore request" do
      it 'does not ignore the membership request' do
        ManageMembershipRequests.should_not_receive(:ignore!)
        post :ignore, id: membership_request.id
      end
      it "redirects to the root path" do
        post :ignore, id: membership_request.id
        response.should redirect_to root_path
      end
    end
  end

end
