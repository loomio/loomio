require 'spec_helper'

describe DashboardController do
  let(:user) { stub_model(User, created_at: Time.zone.now) }
  let(:app_controller) { controller }

  before do
    sign_in user
    app_controller.stub(:authorize!).and_return(true)
    app_controller.stub(:prepare_segmentio_data)
  end

  context "views homepage" do
    it "succeeds" do
      get :show
      response.should be_success
    end
  end
end
