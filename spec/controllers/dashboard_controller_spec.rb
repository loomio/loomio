require 'rails_helper'

describe DashboardController do
  let(:user) { FactoryGirl.create(:user) }
  let(:app_controller) { controller }

  before do
    sign_in user
    app_controller.stub(:authorize!).and_return(true)
  end

  context "views homepage" do
    it "succeeds" do
      get :show
      puts response.body
      response.should be_success
    end
  end
end
