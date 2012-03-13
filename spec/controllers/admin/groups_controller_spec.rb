require 'spec_helper'

describe Admin::GroupsController do
  let(:user) { double("user") }
  context "logged-in admin user views groups" do
    before :each do
      user.stub :admin? => true
      sign_in user
    end

    it "should display all groups" do
      get :index
      response.should be_success
    end
  end

  context "logged-in non-admin user views groups" do
    before :each do
      user.stub :admin? => false
      sign_in user
    end

    it "should redirect to user's groups index" do
      get :index
      response.should be_redirect
    end
  end

  context "logged-out user views groups" do
    it "should redirect to login page" do
      sign_in nil
      get :index
      response.should redirect_to(new_user_session_url)
    end
  end
end
