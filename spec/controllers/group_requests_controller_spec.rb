require 'spec_helper'

describe GroupRequestsController do
  let(:group_request) { build :group_request }

  describe "#new" do
    before do
      GroupRequest.stub(:new => group_request)
      get :new
    end

    it "should assign a GroupRequest object" do
      assigns(:group_request).should eq(group_request)
    end

    it "should successfully render the group request page" do
      response.should be_success
      response.should render_template("new")
    end
  end

  describe "#create" do
    it "should redirect to the confirmation page" do
      put :create, group_request: group_request.attributes
      response.should redirect_to(group_request_confirmation_url)
    end
  end

  describe "#confirmation" do
    it "should successfully render the confirmation page" do
      get :confirmation
      response.should be_success
      response.should render_template("confirmation")
    end
  end

  describe "#verify" do
    before { GroupRequest.stub(:find_by_token).and_return(group_request) }

    context "group_request has not yet been verified" do
      it "sets the status to verified" do
        group_request.should_receive(:verify!)
        put :verify, token: group_request.token
      end
      it "should render the verified page" do
        put :verify, token: group_request.token
        response.should render_template("verify")
      end
    end
    context "group_request has been verified" do
      before { group_request.stub(:unverified?).and_return(false) }
      it "renders the invitation_accepted_error_page" do
        put :verify, token: group_request.token
        response.should render_template("invitation_accepted_error_page")
      end
    end
  end

  describe "#start_new_group" do
    before do
    end
    context "token is correct" do
      context "group request status is approved" do
        it "sets the start_new_group session variable" do
        end
        context "user is signed in" do
          it "redirects to the group page" do
          end
        end
      end
      context "group request status is accepted" do
        it "redirects to the group page" do
        end
      end
    end
    context "token is incorrect" do
      context "group request is approved"
      context "group request is unverified"
      context "group request is "
      it "renders the invalid start group link page"
    end
  end
end
