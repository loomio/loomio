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
    # before { StartGroupMailer.stub_chain(:verification, :deliver).and_return(true) }

    it 'should send a verification email' do
      StartGroupMailer.should_receive(:verification).and_return(stub(deliver: true))
      put :create, group_request: group_request.attributes
    end
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
    render_views
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
      before { group_request.stub(:verified?).and_return(true) }
      it "renders the invitation_verified_error_page" do
        put :verify, token: group_request.token
        response.body.should have_content I18n.t('error.group_request_already_verified')
      end
    end
  end
end
