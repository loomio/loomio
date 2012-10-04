require 'spec_helper'

describe GroupRequestsController do
  let(:group_request) { build_stubbed :group_request }
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
    before { GroupRequest.stub(:create!) }

    it "should create a GroupRequest object" do
      GroupRequest.should_receive(:create!)
      put :create, :group_request => group_request.attributes
    end

    it "should redirect to the confirmation page" do
      put :create, :group_request => group_request.attributes
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

end
