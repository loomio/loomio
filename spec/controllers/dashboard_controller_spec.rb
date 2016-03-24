require 'rails_helper'

describe DashboardController do
  let(:user) { FactoryGirl.create(:user) }
  let(:app_controller) { controller }

  before do
    sign_in user
    allow(app_controller).to receive(:authorize!).and_return(true)
  end

  context "views homepage" do
    it "succeeds" do
      get :show
      response.should be_success
    end
  end
end
