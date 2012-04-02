require 'spec_helper'

describe HomeController do
  context "signed-in user" do
    before :each do
      user = User.make!
      sign_in user
    end

    context "views homepage" do
      it "succeeds" do
        get :index
        response.should be_success
      end
    end
  end

  context "signed-out user" do
    context "views homepage" do
      it "succeeds" do
        get :index
        response.should be_success
      end
    end
  end
end
