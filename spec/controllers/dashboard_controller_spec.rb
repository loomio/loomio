require 'spec_helper'

describe DashboardController do
  let(:user) { stub_model(User) }
  let(:app_controller) { controller }

  before do
    sign_in user
    app_controller.stub(:authorize!).and_return(true)
  end

  context "views homepage" do
    it "succeeds" do
      get :show
      response.should be_success
    end
  end
end
