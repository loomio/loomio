require 'spec_helper'

describe GroupRequestsController do
  let(:group_request) { build :group_request }
  let(:setup_group) { stub(setup: true) }
  let(:user) { create :user }

  describe "#create" do
    context "group_request is saved" do
      before { SetupGroup.stub(:new).and_return(setup_group) }
      it "creates a new SetupGroup" do
        SetupGroup.should_receive(:new).and_return(setup_group)
        put :create, group_request: group_request.attributes
      end
      it "approves the group request" do
        setup_group.should_receive(:setup)
        put :create, group_request: group_request.attributes
      end
      it "should redirect to the confirmation page" do
        put :create, group_request: group_request.attributes
        response.should redirect_to(confirmation_group_requests_url)
      end
    end
    context "group_request does not save" do
      before { group_request.stub(:save).and_return(false) }
      context "paying subscription" do
        it "should render to the subscription action" do
          put :create, group_request: group_request.attributes,
                       group_request: { paying_subscription: 'true' }
          response.should render_template 'subscription'
        end
      end
      context "not paying subscription" do
        it "should render to the pwyc action" do
          put :create, group_request: group_request.attributes,
                       group_request: { paying_subscription: 'false' }
          response.body.should render_template 'pwyc'
        end
      end
    end
  end

  describe "#confirmation" do
    it "should successfully render the confirmation page" do
      get :confirmation
      response.should be_success
      response.should render_template("confirmation")
    end
  end
end
